create database monitor;
\c monitor;

-- TODO: mem limit foreach hubuser
create table hubuser (
  id serial primary key, 
  username varchar(64) not null
);

create table container (
  id serial primary key, 
  project_id     int references project (id),
  container_name varchar(64) not null
);

create table project (
  id serial primary key,
  project varchar(64) not null
);

create table containerstats_current (
  id serial      primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  cpuload        int not null, -- tizezrelek
  memoryusage    int not null, -- byte
  pids           int not null
);

create table containerstats_aggregate (
  id             serial primary key, 
  hubuser_id     int references hubuser (id),
  container_id   int references container (id),
  last_read      timestamp not null default now(),
  net_i          int not null, -- byte
  net_o          int not null, -- byte
  block_i        int not null, -- byte
  block_o        int not null  -- byte
);


-- TODO: host metrikák
