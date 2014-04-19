---
--- pgcharts model
---

create extension if not exists btree_gist;
create extension if not exists base36;
create extension if not exists base36_gist;

create schema if not exists pgcharts;

create table pgcharts.db
(
  dbname      text primary key,
  description text,
  dbhost      text,
  dbport      integer,
  dbuser      text,
  dbpass      text
);

create table pgcharts.groups
(
  gname         text primary key,
  description   text,
  has_snapshot  boolean  
);

create table pgcharts.users
(
  login      text primary key,
  public_key text
);

create table pgcharts.usergroup
(
  gname    text references pgcharts.groups(gname),
  login    text references pgcharts.users(login),
  primary key(gname, login)
);

create table pgcharts.usage
(
  dbname  text references pgcharts.db(dbname),
  gname   text references pgcharts.groups(gname),
  primary key(dbname, gname)
);

-- the minvalue is just so that we begin with 3 letters URLs
create sequence pgcharts.query_id_seq minvalue 10000;

create table pgcharts.query
(
  id         base36 not null default nextval('pgcharts.query_id_seq') primary key,
  sql        text,
  x_col      text,
  y_col      text,
  chart_type text
);

alter sequence pgcharts.query_id_seq owned by pgcharts.query.id;

create table pgcharts.query_history
(
  id     base36,
  used   tstzrange,
  sql    text,
  exclude using gist (id with =, used with &&)
);

create sequence pgcharts.query_snapshots_id_seq minvalue 100000;

create table pgcharts.query_snapshots
(
  id     base36 not null default nextval('pgcharts.query_snapshots_id_seq'),
  query  base36 references pgcharts.query(id),
  source regclass, -- pgclass oid of the table where the snapshot data is stored
  primary key(id, query)
);

alter sequence pgcharts.query_snapshots_id_seq
      owned by pgcharts.query_snapshots.id;
