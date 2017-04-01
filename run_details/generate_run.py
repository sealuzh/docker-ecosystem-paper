#!/usr/bin/python


# Do not judge a man by the quality of his research code… 
# while his intentions were good, his will broke under the 
# time pressure of the conference submission deadline. 
# ...And now stop complaining and enjoy the perils of reproducibility. (J.C.)

import psycopg2
import sys
 
 
def main():
    # get a connection, if a connect cannot be made an exception will be raised here
    conn = psycopg2.connect(host=sys.argv[1], database=sys.argv[2], user=sys.argv[3], password=sys.argv[4],port=sys.argv[5])
                                
    # conn.cursor will return a cursor object, you can use this cursor to perform queries
    cursor = conn.cursor()

    run_diff_breakdown(cursor)

  


def row_format(row):
    return " & ".join(row)



### RUN Diff Type queries

def run_diff_breakdown(cursor):
    print "Breakdown of RUN Diff Type instructions"

    print "Breakdown of All Changes"
    print row_format(['All', 'Add', 'Mod', 'Rem'])

    diff_types = ['', 'Add', 'Update', 'Del']
    top_list = [0, 1000, 100]
    rows = []
    row_index = 0
    for label, run_list in all_lists().iteritems():
        rows.append([label])
        for top in top_list:
            print label + ", Top: " + str(top)
            for diff_type in diff_types:
                value = round(run_diff_proportion(cursor, run_list, diff_type, top), 2)
                color = cellcolor(value)
                column = cellcolor_format(color) + str(value)
                print diff_type + ": " + str(column)
                rows[row_index].append(column)
        row_index += 1

    for row in rows:
        print row_format(row)

        
def cellcolor_format(color):
    if color == "": return ""
    return "\cellcolor{" + color + "} "

def cellcolor(value):
    #\cellcolor{mid}
    if value < 0.01:
        return ""

    if value < 0.02: return "lowest"
    if value < 0.05: return "low"
    if value < 0.10: return "midlow"
    if value < 0.2:  return "mid"
    if value < 0.4:  return "midhigh"
    if value < 0.5:  return "high"

    return "highest"

    """0.00 - white
    0.01 - lowest
    0.02 - 0.05 - low
    0.06 - 0.10 - midlow
    0.11 - 0.2 - mid
    0.21 - 0.4 - midhigh
    0.41 - 0.5 - high"""


def run_diff_proportion(cursor, executable_list = '', diff_type = '', top = 0):
    population = float(run_diff_count(cursor, '', diff_type, top))
    count = run_diff_count(cursor, executable_list, diff_type, top)
    return count / population


def run_diff_count(cursor, executable_list = '', diff_type = '', top = 0):
    top_join, top_where = diff_top_query_sql_parts(top)
    diff_type_where = diff_type_query_sql_part(diff_type)
    executable_list_where = "" if executable_list == '' else "executable in %(executable_list)s"

    where = ["diff_state = 'COMMIT_COMMIT'", 
             "instruction = 'RUN'", 
             executable_list_where,
             top_where,
             diff_type_where]

    where = filter(None, where) # remove empty elements

    
    sql = "select count(*) FROM diff d join diff_type dt on d.diff_id = dt.diff_id " + top_join + " WHERE " + " and ".join(where)

    #use mogrify instead of execute if you want to see the resulting SQL statement
    if executable_list == '':
        #print cursor.mogrify(sql, { 'type' : diff_type + "%%"})
        cursor.execute(sql, { 'type' : diff_type + "%%"})
    else:
        cursor.execute(sql, { 'type' : diff_type + "%%",'executable_list' : tuple(executable_list), })

    return cursor.fetchone()[0]

def diff_type_query_sql_part(diff_type):
    if diff_type == '':
        return ''

    return " change_type like %(type)s "

def diff_top_query_sql_parts(top):
    if top == 100 or top == 1000:
        # restrict to top100 or top1000 projects if param given
        top_join = " join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id "
        top_where = " rdt.repo_path in (select distinct(repo_path) from top" + str(top) + ")"
        return top_join, top_where

    return "", ""


### RUN current queries

def run_breakdown(cursor):
    print "Breakdown of RUN instructions"
    print "All & T1000 & T100"

    # get population numbers
    all_population = float(run_population(cursor))
    t1000_population = float(run_population(cursor, 1000))
    t100_population = float(run_population(cursor, 100))

    #print all_population, t1000_population, t100_population

    sum_all = 0
    sum_t1000 = 0
    sum_t100 = 0
    for label, run_list in all_lists().iteritems():
        all = run_count(cursor, run_list)
        t1000 = run_count(cursor, run_list, 1000)
        t100 = run_count(cursor, run_list, 100)

        all_proportional   = round(all / all_population, 3)
        t1000_proportional = round(t1000 / t1000_population, 3)
        t100_proportional  = round(t100 / t100_population, 3)

        sum_all += all
        sum_t1000 += t1000
        sum_t100 += t100

        print row_format([label, str(all_proportional), str(t1000_proportional), str(t100_proportional)])


    # 'Other' is the remaining %
    all_other = round((all_population - sum_all) / all_population, 3)
    t1000_other = round((t1000_population - sum_t1000) / t1000_population, 3)
    t100_other = round((t100_population - sum_t100) / t100_population, 3)
    print row_format(["Other", str(all_other), str(t1000_other), str(t100_other)])  


def run_population(cursor, top = 0):
    top_join, top_where = top_query_sql_parts(top)
    cursor.execute("select count(*) from df_run r " + top_join + " where r.current = true " + top_where)
    return cursor.fetchone()[0]    

def run_count(cursor, executable_list, top = 0):
    top_join, top_where = top_query_sql_parts(top)
    cursor.execute("select count(*) from df_run r " + top_join + " where r.current = true and r.executable in %(executable_list)s " + top_where, { 'executable_list' : tuple(executable_list), })
    return cursor.fetchone()[0]


def top_query_sql_parts(top):
    if top == 100 or top == 1000:
        # restrict to top100 or top1000 projects if param given
        top_join = " join snapshot s on s.snap_id = r.snap_id join dockerfile d on d.dock_id = s.dock_id "
        top_where = " and d.repo_path in (select repo_path from top" + str(top) + ")"
        return top_join, top_where

    return "", ""


def all_lists():
    return { 'Dependencies' : dependencies_list(), 'Filesystem' : filesystem_list(), 'Build/Execute' : build_execute_list(), 
             'Environment' : environment_list(), 'Permissions' : permissions_list()}

def dependencies_list():
    return ['apt-get', 'npm', 'yum', 'curl', 'pip', 'wget', 'git', 'apk', 'gem', 'bower', 'add-apt-repository', 'dpkg', 'rpm', 'bundle', 'apt-key', 'pip3', 'dnf', 'conda', 'cabal', 'easy_install', 'nvm', 'lein',     'composer', 'mvn', 'apk-install', 'apt', 'pecl', 'puppet', 'svn', 'godep']

def filesystem_list():
    return ['echo', 'mkdir', 'rm', 'cd', 'tar', 'sed', 'ln', 'mv', 'cp', 'unzip', 'pacman', 'touch', 'ls', 'cat', 'find']

def build_execute_list():
    return ['make', 'go', './configure', '/bin/bash', 'bash', 'python', 'service', 'sh', 'cmake', 'install', 'python3']
    
def environment_list():
    return ['set', 'export', 'source', 'virtualenv']

def permissions_list():
    return ['chmod', 'chown', 'useradd', 'groupadd', 'adduser', 'usermod', 'addgroup']
           

if __name__ == "__main__":
    main()
