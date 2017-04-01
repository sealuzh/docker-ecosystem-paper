-- create a 'unique' violated_rules view
-- containing only a single entry for a rule violation per dockerfile
-- + some data cleaning   
create view violated_rules_unique as 
    SELECT v.violated_rules as violated_rule, v.dock_id, d.repo_id, count(*) FROM public.violated_rules v
    join dockerfile d on d.dock_id = v.dock_id
    where violated_rules not like '/home/user%' and violated_rules not in ('unexpected', 'Prelude.head:', '/dev/stdin:','starting','Error', '-c:', 'unix')
    group by v.violated_rules, v.dock_id, d.repo_id;
    
/*
create view violated_rules_unique as 
    SELECT violated_rules as violated_rule, dock_id, count(*) FROM public.violated_rules
    where violated_rules not like '/home/user%' and violated_rules not in ('unexpected', 'Prelude.head:', '/dev/stdin:','starting','Error', '-c:', 'unix')
    group by violated_rules, dock_id;
*/

-- drop the view
drop view violated_rules_unique;

-- get the top rules and their number of occurences across dockerfiles
select violated_rule, count(*) from violated_rules_unique
group by violated_rule
order by 2 desc;

select distinct violated_rule from violated_rules_unique;

-- export violated_rule, dock_id, repo_stars
select v.violated_rule, v.dock_id, d.i_stargazers from violated_rules_unique v
join dockerfile d on v.dock_id = d.dock_id
order by v.violated_rule;

-- export violated_rule, dock_id, repo_stars, repo_id
select v.violated_rule, v.dock_id, d.i_stargazers, d.repo_id from violated_rules_unique v
join dockerfile d on v.dock_id = d.dock_id
order by v.violated_rule;

-- export violated_rule, dock_id, stars, repo_path, i_forks, i_owner_type, docker_path
select v.violated_rule, v.dock_id, d.i_stargazers, d.repo_path, d.i_forks, d.i_owner_type, d.docker_path from violated_rules_unique v
join dockerfile d on v.dock_id = d.dock_id
order by v.violated_rule;

-- select * from violated_rules limit 2000
-- select * from violated_rules_unique limit 2000

/* Instruction Density */
-- need a temporary table
create table tmp_violated_rules as
select dock_id, count(*) from violated_rules v
where violated_rules not like '/home/user%' and violated_rules not in ('unexpected', 'Prelude.head:', '/dev/stdin:','starting','Error', '-c:', 'unix')
group by dock_id

-- temporary view for easier export
create view tmp_instruction_view as
select s.dock_id, d.repo_path, d.docker_path, s.instructions, t.count from snapshot s
join dockerfile d on d.dock_id = s.dock_id
join tmp_violated_rules t on s.dock_id = t.dock_id
where s.current

                                                              
/* some stats about rule violations */                                                             

-- number of rule violations
select count(*) from violated_rules_unique v
join dockerfile d on v.dock_id = d.dock_id

-- number of rule violations of projects with more than X stars
select count(*) from violated_rules_unique v
join dockerfile d on v.dock_id = d.dock_id
where d.i_stargazers >= 10

-- number of projects with less than X stars
select count(distinct repo_id) from dockerfile
where i_stargazers < 10

-- number of projects with more than X stars
select count(distinct repo_id) from dockerfile
where i_stargazers > 10

-- average number of stars
select avg(e.stars) from (
select avg(d.i_stargazers) stars from dockerfile d
group by repo_id) e

/*
create view top1000 as 
select repo_id, repo_path, max(i_stargazers) from dockerfile
group by repo_id, repo_path
order by 3 desc
limit 1000;

create view top100 as 
select repo_id, repo_path, max(i_stargazers) from dockerfile
group by repo_id, repo_path
order by 3 desc
limit 100;
*/

-- dirty intermediate view to filter duplicats for top100
create view tmp_top100 as 
select d.repo_id, d.repo_path, max(d.i_stargazers) stars from dockerfile d
group by d.repo_id, d.repo_path
order by 3 desc
limit 200
drop view tmp_top100

-- dirty intermediate view to filter duplicats for top1000
create view tmp_top1000 as 
select d.repo_id, d.repo_path, max(d.i_stargazers) stars from dockerfile d
group by d.repo_id, d.repo_path
order by 3 desc
limit 1300
drop view tmp_top1000

-- get the top 100 projects based on their star rating
create table top100 as
select t.repo_id, t.repo_path, t.stars from tmp_top100 t
where t.repo_path = (select max(repo_path) from tmp_top100 where repo_id = t.repo_id)
limit 100

-- get the top 1000 projects based on their star rating
create table top1000 as
select t.repo_id, t.repo_path, t.stars from tmp_top1000 t
where t.repo_path = (select max(repo_path) from tmp_top1000 where repo_id = t.repo_id)
limit 1000


/*
create view top10000 as 
select repo_id, repo_path, max(i_stargazers) from dockerfile
group by repo_id, repo_path
order by 3 desc
limit 10000;
*/

select repo_id, count(distinct repo_path) from dockerfile
group by repo_id
having count(distinct repo_path) > 1

-- get the number of projects within the top 100 without any quality issue
select count(distinct d.repo_id) from top100 t
join dockerfile d
on d.repo_path = t.repo_path
where not exists (select * from violated_rules_unique v where v.dock_id = d.dock_id)
-- > 19 projects

/*
select distinct a.repo_id, a.repo_path, b.repo_path from dockerfile a, dockerfile b
where a.repo_id = b.repo_id and a.repo_path <> b.repo_path

select distinct a.repo_id, a.repo_path, b.repo_path from top100 a, top100 b
where a.repo_id = b.repo_id and a.repo_path <> b.repo_path

select distinct a.repo_id, a.repo_path, b.repo_path from top1000 a, top1000 b
where a.repo_id = b.repo_id and a.repo_path <> b.repo_path
*/

-- get the number of projects within the top 1000 without any quality issue
select count(distinct d.repo_id) from top1000 t
join dockerfile d
on d.repo_path = t.repo_path
where not exists (select * from violated_rules_unique v where v.dock_id = d.dock_id)
-- > 201 projects

-- get the number of projects without any quality issue
select count(distinct d.repo_id) from dockerfile d
where not exists (select * from violated_rules_unique v where v.dock_id = d.dock_id)
-- > 6059 projects
-- > 37334 distinct projects

-- get the number of quality issues of the top100 projects
select count(*) from top100 t
join dockerfile d
on d.repo_path = t.repo_path
join violated_rules_unique v
on v.dock_id = d.dock_id

-- get the average number of quality issues of the top100 projects
select avg(a.num) from (
select t.repo_path, count(distinct v.violated_rule) num from top100 t
join dockerfile d
on d.repo_path = t.repo_path
left join violated_rules_unique v
on v.dock_id = d.dock_id
group by t.repo_path
) a
-- > 3.23

-- get the number of quality issues of the top1000 projects
select count(*) from top1000 t
join dockerfile d
on d.repo_path = t.repo_path
join violated_rules_unique v
on v.dock_id = d.dock_id

-- get the average number of quality issues of the top1000 projects
select avg(a.num) from (
select t.repo_path, count(distinct v.violated_rule) num from top1000 t
join dockerfile d
on d.repo_path = t.repo_path
left join violated_rules_unique v
on v.dock_id = d.dock_id
group by t.repo_path
) a
-- > 3.50

-- get the average number of quality issues across all projects
select avg(a.num) from (
select d.repo_id, count(distinct v.violated_rule) num from dockerfile d
left join violated_rules_unique v
on v.dock_id = d.dock_id
group by d.repo_id
) a
-- > 3.12

-- get the average number of quality issues across all projects having less than 5 stars
select avg(a.num) from (
select d.repo_id, count(distinct v.violated_rule) num from dockerfile d
left join violated_rules_unique v
on v.dock_id = d.dock_id
where d.i_stargazers >= 5
group by d.repo_id
) a
-- > 3.41

-- get the number of repos of Organizations
select count(distinct repo_id) from dockerfile
where i_owner_type = 'Organization';
-- > 11609 Organizations

-- number of Organizations having at least one violated rule
select count(distinct d.repo_id) from dockerfile d
where d.i_owner_type = 'Organization' and exists (select * from violated_rules_unique v where v.dock_id = d.dock_id)
-- > 10302 i.e. 89% have violated rules

-- get the number of repos of Users
select count(distinct repo_id) from dockerfile
where i_owner_type = 'User';
-- > 25725

-- number of Users having at least one violated rule
select count(distinct d.repo_id) from dockerfile d
where d.i_owner_type = 'User' and exists (select * from violated_rules_unique v where v.dock_id = d.dock_id)
-- > 22713 i.e. 88% have violated rules

select avg(num) from (
select repo_id, count(distinct violated_rule) num from violated_rules_unique
group by repo_id) d
-- > on average 3.5 violated rules

select avg(num) from (
select v.repo_id, count(distinct v.violated_rule) num from violated_rules_unique v
join dockerfile d on d.dock_id = v.dock_id
where d.i_owner_type = 'Organization'
group by v.repo_id) d
-- > on average 3.6 violated rules for organizations

select avg(num) from (
select v.repo_id, count(distinct v.violated_rule) num from violated_rules_unique v
join dockerfile d on d.dock_id = v.dock_id
where d.i_owner_type = 'User'
group by v.repo_id) d
-- > on average 3.5 violated rules for users

select avg(num) from (
select v.repo_id, count(distinct v.violated_rule) num from violated_rules_unique v
join dockerfile d on d.dock_id = v.dock_id
where d.i_stargazers >= 10
group by v.repo_id) d
-- > on average 3.9 violated rules for repos with >= 10 stars

select avg(num) from (
select v.repo_id, count(distinct v.violated_rule) num from violated_rules_unique v
join dockerfile d on d.dock_id = v.dock_id
where d.repo_id in (select repo_id from top100)
group by v.repo_id) d
-- > on average 3.9 violated rules for top100 repos

select avg(num) from (
select v.repo_id, count(distinct v.violated_rule) num from violated_rules_unique v
join dockerfile d on d.dock_id = v.dock_id
where d.repo_id in (select repo_id from top1000)
group by v.repo_id) d
-- > on average 3.9 violated rules for top1000 repos



/* multi process management */
drop view multi_process;
create view multi_process as
select d.repo_path, d.i_owner_type, d.i_stargazers, s.instructions, 
   case when c.executable like '%supervisor%' then 'supervisord' 
   when c.executable like '%runit%' then 'runit' 
   when c.executable like '%systemd%' then 'system.d'  
   when c.executable like '%upstart%' then 'upstart' 
   when c.executable like '%monit' then 'monit' 
   when c.executable like '%s6%' then 's6' end as multi_process_tool, 'cmd'::text as type from df_cmd c
join snapshot s on s.snap_id = c.snap_id
join dockerfile d on d.dock_id = s.dock_id
where c.current and (c.executable like '%supervisor%' or c.executable like '%runit%' 
                     or c.executable like '%systemd%' or c.executable like '%upstart%'
                     or c.executable like '%monit' or c.executable like '%s6%')               
UNION ALL
select d.repo_path, d.i_owner_type, d.i_stargazers, s.instructions, 
   case when c.arg like '%supervisor%' then 'supervisord' 
   when c.arg like '%runit%' then 'runit' 
   when c.arg like '%systemd%' then 'system.d'  
   when c.arg like '%upstart%' then 'upstart' 
   when c.arg like '%monit' then 'monit' 
   when c.arg like '%s6%' then 's6' end as multi_process_tool, 'entrypoint'::text as type from df_entrypoint c
join snapshot s on s.snap_id = c.snap_id
join dockerfile d on d.dock_id = s.dock_id
where c.current and (c.arg like '%supervisor%' or c.arg like '%runit%' 
                     or c.arg like '%systemd%' or c.arg like '%upstart%'
                     or c.arg like '%monit' or c.arg like '%s6%')  

select multi_process_tool, count(*) from multi_process
group by multi_process_tool

select multi_process_tool, type, count(*) from multi_process
group by multi_process_tool, type

select multi_process_tool, type, count(*) from multi_process m
join top1000 t on t.repo_path = m.repo_path
group by multi_process_tool, type

-- number of repositories not using multi process tools (in cmd or entrypoint)
select count(distinct repo_path) from dockerfile
where repo_path not in (select repo_path from multi_process)

-- number of repositories using multi process tools (in cmd or entrypoint)
select count(distinct repo_path) from multi_process
-- > ~3% of repositories use multi process tooling

-- number of repositories
select count(distinct repo_path) from dockerfile

select count(distinct repo_path) from multi_process
where i_stargazers <= 10

select i_owner_type, count(distinct repo_path) from multi_process
group by i_owner_type
-- > 28% organizations

select i_owner_type, count(distinct repo_path) from dockerfile
group by i_owner_type
-- > 32% organizations

/* stats */
-- supervisord usage (CMD)
select count(*) from df_cmd c
where c.executable like '%supervisor%' and current

-- supervisord usage (ENTRYPOINT)
select count(*) from df_entrypoint c
where c.arg like '%supervisor%' and current

-- runit usage (CMD)
select count(*) from df_cmd c
where c.executable like '%runit%' and current

-- runit usage (ENTRYPOINT)
select count(*) from df_entrypoint c
where c.arg like '%runit%' and current

-- system.d usage (CMD)
select count(*) from df_cmd c
where c.executable like '%systemd%' and current

-- system.d usage (ENTRYPOINT)
select count(*) from df_entrypoint c
where c.arg like '%systemd%' and current

-- upstart usage (CMD)
select count(*) from df_cmd c
where c.executable like '%upstart%' and current

-- upstart usage (ENTRYPOINT)
select count(*) from df_entrypoint c
where c.arg like '%upstart%' and current

-- monit usage (CMD)
select count(*) from df_cmd c
where c.executable like '%monit' and current

-- monit usage (ENTRYPOINT)
select count(*) from df_entrypoint c
where c.arg like '%monit' and current

-- s6 usage (CMD)
select count(*) from df_cmd c
where c.executable like '%s6%' and current

-- s6 usage (ENTRYPOINT)
select count(*) from df_entrypoint c
where c.arg like '%s6%' and current

-- something....
select * from cmd_params c
join df_cmd d on c.run_id = d.snap_id
where d.executable like '%supervisor%' and current;

select count(*) from df_run r
where r.executable in ('apt-get', 'apt', 'apt-cache', 'dpkg', 'yum', 'dnf', 'pkg') and run_params like '%supervisor%'

select * from df_run r
where r.executable in ('apt-get', 'apt', 'apt-cache', 'dpkg', 'yum', 'dnf', 'pkg') and run_params like '%runit%'
limit 1000

drop view multi_process_install;
create view multi_process_install as
select d.repo_path, d.i_owner_type, d.i_stargazers, s.instructions, 
   case when p.run_params like '%supervisor%' then 'supervisord' 
   when p.run_params like '%runit%' then 'runit' 
   when p.run_params like 'systemd' then 'system.d'  
   when p.run_params like 'upstart' then 'upstart' 
   when p.run_params like 'monit' then 'monit' 
   when p.run_params like 's6-svscan' then 's6' end as multi_process_tool from df_run r
join run_params p on p.run_id = r.run_id
join snapshot s on s.snap_id = r.snap_id
join dockerfile d on d.dock_id = s.dock_id
where r.current and r.executable in ('apt-get', 'apt', 'apt-cache', 'dpkg', 'yum', 'dnf', 'pkg') and 
(p.run_params like '%supervisor%' or p.run_params like '%runit%' 
                     or p.run_params like 'systemd' or p.run_params like 'upstart'
                     or p.run_params like 'monit' or p.run_params like 's6-svscan')


select multi_process_tool, count(*) from multi_process_install
group by multi_process_tool

select count(*) from multi_process_install m
join top1000 t on t.repo_path = m.repo_path
-- > 1000 -> 58
-- > 100 -> 0

select count(*) from multi_process m
join top1000 t on t.repo_path = m.repo_path
-- > 1000 -> 52
-- > 100 -> 0

select m.multi_process_tool, count(*) from multi_process_install m
join top10000 t on t.repo_path = m.repo_path
group by multi_process_tool

select p.run_params, count(*) from df_run r
join run_params p on p.run_id = r.run_id
where r.executable in ('apt-get', 'apt', 'apt-cache', 'dpkg', 'yum', 'dnf', 'pkg') and r.current and
(p.run_params like '%supervisor%' or p.run_params like '%runit%' 
                     or p.run_params like 'systemd' or p.run_params like 'upstart'
                     or p.run_params like 'monit' or p.run_params like 's6-svscan')
group by p.run_params


select * from df_run r
where run_params like '%s6-svscan%'

select * from run_params r
where run_params like 'runit'
                     

-- number of dockerfiles using entrypoint
select count(distinct s.snap_id) from df_entrypoint e
join snapshot s on s.snap_id = e.snap_id
where e.current

-- number of dockerfiles using cmd
select count(distinct s.snap_id) from df_cmd c
join snapshot s on s.snap_id = c.snap_id
where c.current

-- number of dockerfiles using cmd and entrypoint
select count(distinct s.snap_id) from snapshot s
join df_cmd c on s.snap_id = c.snap_id
join df_entrypoint e on s.snap_id = e.snap_id
where c.current and e.current


select d.repo_path, d.i_stargazers, d.i_subscribers, d.i_watchers, d.i_owner_type, d.i_forks from dockerfile d
limit 100

select count(distinct repo_id) from dockerfile

select count(distinct dock_id) from dockerfile;

select dock_id, count(distinct violated_rule) from violated_rules_unique
group by dock_id
having count(distinct violated_rule) >= ALL (select count(distinct violated_rule) from violated_rules_unique group by dock_id)

select count(*) from top100 t
join dockerfile d
on d.repo_path = t.repo_path
join snapshot s
on s.dock_id = d.dock_id
where s.current

select count(*) from top100 t
join dockerfile d
on d.repo_path = t.repo_path
join snapshot s
on s.dock_id = d.dock_id
join df_from f
on f.snap_id = s.snap_id
where s.current

select * from dockerfile
where i_size > 30
order by i_size asc
limit 1000

select diff_state from diff
limit 100