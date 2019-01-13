psql --user postgres <<EOF
\x
create database monitor;
\c monitor;

create table hubuser (
  id serial primary key, 
  username varchar(64) not null
);

create table project (
  id serial primary key,
  project varchar(64) not null
);

create table container (
  id serial primary key, 
  project_id     int references project (id),
  hubuser_id     int references hubuser (id),
  container_name varchar(64) not null
);

create table system (
id serial primary key,  
total_cpu        bigint not null, -- tizezrelek
total_mem     bigint not null, -- byte
last_read      timestamp not null default now()
);

create table containerstats_mem (
  id serial      primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  memoryusage    bigint not null -- byte
);

create table containerstats_cpuload (
  id serial      primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  cpuload        int not null -- tizezrelek
);

create table containerstats_total_cpu (
  id serial      primary key, 
  container_id   int references container (id),
  total_cpu      bigint not null, -- tizezrelek
  last_read      timestamp not null default now()
);

create table containerstats_pids (
  id serial      primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  pids           int not null
);

create table containerstats_net_i (
  id             serial primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  net_i          bigint not null -- byte
);

create table containerstats_net_o (
  id             serial primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  net_o          bigint not null -- byte
);

create table containerstats_block_i (
  id             serial primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  block_i        bigint not null -- byte
);

create table containerstats_block_o (
  id             serial primary key, 
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  block_o        bigint not null  -- byte
);



CREATE USER usage_viewer WITH PASSWORD 'whatisusage';
GRANT CONNECT ON DATABASE monitor to usage_viewer;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO usage_viewer;
GRANT USAGE ON SCHEMA public to usage_viewer;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO usage_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usage_viewer;
EOF

