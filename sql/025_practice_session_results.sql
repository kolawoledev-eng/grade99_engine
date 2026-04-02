-- One row per finished national practice session (Option A) for leaderboards.

create table if not exists practice_session_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  exam varchar(50) not null,
  subject varchar(120) not null,
  year int,
  difficulty varchar(20),
  practise_mode varchar(20) not null check (practise_mode in ('exam', 'study')),
  correct_count int not null check (correct_count >= 0),
  total_count int not null check (total_count >= 1 and total_count <= 200),
  score_pct numeric(7, 3),
  created_at timestamptz not null default now()
);

create index if not exists idx_psr_exam_created
  on practice_session_results(exam, created_at desc);

create index if not exists idx_psr_user_exam_created
  on practice_session_results(user_id, exam, created_at desc);

-- Top N for a national exam and optional time window (p_since null = all-time).
create or replace function public.leaderboard_top(
  p_exam text,
  p_since timestamptz,
  p_limit int default 50
) returns json
language sql
stable
as $$
  with agg as (
    select r.user_id,
           sum(r.correct_count)::bigint as points,
           sum(r.total_count)::bigint as answered,
           count(*)::bigint as sessions
    from practice_session_results r
    where upper(r.exam) = upper(trim(p_exam))
      and (p_since is null or r.created_at >= p_since)
    group by r.user_id
  ),
  ranked as (
    select row_number() over (
             order by points desc,
                      (points::numeric / nullif(answered, 0)) desc nulls last,
                      user_id asc
           )::int as rank,
           user_id, points, answered, sessions
    from agg
  ),
  final as (
    select r.rank,
           r.user_id,
           case
             when trim(coalesce(u.first_name, '')) = '' and trim(coalesce(u.last_name, '')) = ''
               then 'Learner'
             when trim(coalesce(u.last_name, '')) = ''
               then trim(u.first_name)
             else trim(u.first_name || ' ' || left(trim(u.last_name), 1) || '.')
           end as display_name,
           r.points,
           r.sessions,
           case when r.answered > 0
                then round((100.0 * r.points / r.answered)::numeric, 1)
                else 0::numeric end as accuracy_pct
    from ranked r
    join users u on u.id = r.user_id
    where coalesce(u.is_deleted, false) = false
    order by r.rank
    limit greatest(1, least(coalesce(nullif(p_limit, 0), 50), 100))
  )
  select coalesce(
    (
      select json_agg(
        json_build_object(
          'rank', f.rank,
          'user_id', f.user_id,
          'display_name', f.display_name,
          'points', f.points,
          'sessions', f.sessions,
          'accuracy_pct', f.accuracy_pct
        )
        order by f.rank
      )
      from final f
    ),
    '[]'::json
  );
$$;
