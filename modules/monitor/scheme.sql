create database monitor;
\c monitor;

-- TODO: mem limit foreach hubuser
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
  container_name varchar(64) not null
);

create table containerstats_mem (
  id serial      primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  memoryusage    bigint not null -- byte
);

create table containerstats_cpuload (
  id serial      primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  cpuload        int not null -- tizezrelek
);

create table containerstats_pids (
  id serial      primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  pids           int not null
);

create table containerstats_net_i (
  id             serial primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  net_i          bigint not null -- byte
);

create table containerstats_net_o (
  id             serial primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  net_o          bigint not null -- byte
);

create table containerstats_block_i (
  id             serial primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  block_i        bigint not null -- byte
);

create table containerstats_block_o (
  id             serial primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  block_o        bigint not null  -- byte
);

create table number_of_ipykernels (
  id             serial primary key, 
  last_read      timestamp not null default now(),
  ipykernels     int not null  -- # of ipykernels
);

-- TODO: host metrikák

#CREATE ROLE readaccess;
#GRANT USAGE ON SCHEMA public TO readaccess;

CREATE USER usage_viewer WITH PASSWORD 'whatisusage';
GRANT CONNECT ON DATABASE monitor to usage_viewer;
\c monitor
#GRANT readaccess TO usage_viewer;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO usage_viewer;
GRANT USAGE ON SCHEMA public to usage_viewer;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO usage_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usage_viewer;

