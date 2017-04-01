# How often are Dockerfiles changed?
## Projects with No. of Revisions:
ALL: `SELECT dock_id, repo_path, docker_path, count(*), I_Watchers as watchers, FIRST_DOCKER_COMMIT as created
FROM dockerfile NATURAL JOIN snapshot
GROUP BY dock_id`
TOP-1000: `SELECT dock_id, repo_path, docker_path, count(*), I_Watchers as watchers, FIRST_DOCKER_COMMIT as created
FROM dockerfile NATURAL JOIN snapshot
where repo_path in (select distinct(repo_path) from top1000)
GROUP BY dock_id
order by repo_path`
## Average:
`SELECT avg(count)
FROM (
SELECT dock_id, count(*)
FROM dockerfile NATURAL JOIN snapshot
GROUP BY dock_id) s`
## Most:
`select max(revisions) from (
    SELECT dock_id, count(*) as revisions
	FROM dockerfile NATURAL JOIN snapshot
	GROUP BY dock_id) as s`

# How large are changes?
ALL: `select diff_id, del, ins, mod, (del+ins+mod) total, 'dummy' dummy
from diff
where diff_state = 'COMMIT_COMMIT'`

# Which instructions are most often changed?
ALL :`SELECT instruction, cast(count(instruction) as float) / (
    select count(*)  FROM diff d join diff_type dt on d.diff_id = dt.diff_id
    WHERE diff_state = 'COMMIT_COMMIT'
) as usage
FROM diff d join diff_type dt on d.diff_id = dt.diff_id
WHERE diff_state = 'COMMIT_COMMIT'
GROUP BY instruction
ORDER BY count(instruction) DESC`

ALL (TOP-1000):`SELECT instruction, cast(count(instruction) as float) / (
    SELECT count(*)
    FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id, diff d
    where d.diff_id = dt.diff_id and d.diff_state = 'COMMIT_COMMIT' and rdt.repo_path in (select distinct(repo_path) from top1000)
) as usage
FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id, diff d
where d.diff_id = dt.diff_id and d.diff_state = 'COMMIT_COMMIT' and rdt.repo_path in (select distinct(repo_path) from top1000)
GROUP BY instruction
ORDER BY count(instruction) DESC`

ADD :`SELECT instruction, cast(count(instruction) as float) / (
    select count(*)  FROM diff d join diff_type dt on d.diff_id = dt.diff_id
    WHERE diff_state = 'COMMIT_COMMIT' and change_type LIKE '%Add%'
) as usage
FROM diff d join diff_type dt on d.diff_id = dt.diff_id
WHERE diff_state = 'COMMIT_COMMIT' and change_type LIKE '%Add%'
GROUP BY instruction
ORDER BY count(instruction) DESC`

ADD (TOP-1000):`SELECT instruction, cast(count(instruction) as float) / (
    SELECT count(*)
    FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id, diff d
    where d.diff_id = dt.diff_id and d.diff_state = 'COMMIT_COMMIT'
    and rdt.repo_path in (select distinct(repo_path) from top1000) and dt.change_type LIKE '%Add%'
) as usage
FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id, diff d
where d.diff_id = dt.diff_id and d.diff_state = 'COMMIT_COMMIT'
and rdt.repo_path in (select distinct(repo_path) from top1000) and dt.change_type LIKE '%Add%'
GROUP BY instruction
ORDER BY count(instruction) DESC`

DEL :`SELECT instruction, cast(count(instruction) as float) / (
    select count(*)  FROM diff d join diff_type dt on d.diff_id = dt.diff_id
    WHERE diff_state = 'COMMIT_COMMIT' and change_type LIKE '%Del%'
) as usage
FROM diff d join diff_type dt on d.diff_id = dt.diff_id
WHERE diff_state = 'COMMIT_COMMIT' and change_type LIKE '%Del%'
GROUP BY instruction
ORDER BY count(instruction) DESC`

DEL (TOP-1000): `SELECT instruction, cast(count(instruction) as float) / (
    SELECT count(*)
    FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id
    where rdt.repo_path in (select distinct(repo_path) from top1000) and change_type LIKE '%Del%'
) as usage
FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id
where rdt.repo_path in (select distinct(repo_path) from top1000) and change_type LIKE '%Del%'
GROUP BY instruction
ORDER BY count(instruction) DESC`

MOD :`SELECT instruction, cast(count(instruction) as float) / (select count(*)  FROM diff_type WHERE change_type LIKE '%Update%') as usage
FROM diff_type
WHERE change_type LIKE '%Update%'
GROUP BY instruction
ORDER BY count(instruction) DESC`

ADD (TOP-1000): `SELECT instruction, cast(count(instruction) as float) / (
    SELECT count(*)
    FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id
    where rdt.repo_path in (select distinct(repo_path) from top1000) and change_type LIKE '%Update%'
) as usage
FROM diff_type dt join repo_diff_type rdt on dt.diff_type_id = rdt.diff_type_id
where rdt.repo_path in (select distinct(repo_path) from top1000) and change_type LIKE '%Update%'
GROUP BY instruction
ORDER BY count(instruction) DESC`


# How often are only Docker files changed? How often are other files changed in the same revision?
## Alone
`SELECT avg(count)
FROM(
SELECT dock_id, count(dock_id)
FROM(SELECT s.snap_id, s.dock_id, count(s.snap_id)
FROM snapshot s NATURAL JOIN changed_files c
WHERE c.range_index = 0
GROUP BY s.snap_id
ORDER BY count ASC) g NATURAL JOIN dockerfile
WHERE g.count = 1
GROUP BY dock_id) f`

## With other
`SELECT avg(count)
FROM(
SELECT dock_id, count(dock_id)
FROM(SELECT s.snap_id, s.dock_id, count(s.snap_id)
FROM snapshot s NATURAL JOIN changed_files c
WHERE c.range_index = 0
GROUP BY s.snap_id
ORDER BY count ASC) g NATURAL JOIN dockerfile
WHERE g.count > 1
GROUP BY dock_id) f`

## Which files are often changed together with Docker files?
### Actual File Names
`select full_file_name, count(full_file_name)
from changed_files
where range_index = 0 and full_file_name != 'Dockerfile'
group by full_file_name
order by count desc`

### Types

ALL:`SELECT file_type, count(file_type)
FROM changed_files
WHERE range_index = 0 and file_type != ''
GROUP BY file_type
ORDER BY count DESC`

TOP-1000:`SELECT file_type, count(file_type)
FROM dockerfile natural join snapshot natural join changed_files
WHERE repo_path in (select distinct(repo_path) from top1000) and range_index = 0 and file_type != ''
GROUP BY file_type
ORDER BY count DESC`
