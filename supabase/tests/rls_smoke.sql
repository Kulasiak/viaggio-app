-- RLS smoke test. Run as superuser on a DB with the migration applied.
-- Users: G = guide, T = tourist (same trip), X = tourist of another trip.
grant usage on schema public, auth to authenticated;
grant all on all tables in schema public to authenticated;
grant all on all sequences in schema public to authenticated;
insert into auth.users values ('00000000-0000-0000-0000-00000000000a'),('00000000-0000-0000-0000-00000000000b'),('00000000-0000-0000-0000-00000000000c');
insert into profiles(id,full_name) values ('00000000-0000-0000-0000-00000000000a','Guide'),('00000000-0000-0000-0000-00000000000b','Tourist'),('00000000-0000-0000-0000-00000000000c','Other');
insert into trips(id,name,guide_id,invite_code) values ('10000000-0000-0000-0000-000000000001','Roma','00000000-0000-0000-0000-00000000000a','ROMA-1'),('10000000-0000-0000-0000-000000000002','Milano','00000000-0000-0000-0000-00000000000c','MI-1');
insert into trip_members values ('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000000a','guide'),('10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000000b','tourist'),('10000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-00000000000c','guide');
insert into documents(user_id,kind,storage_path) values ('00000000-0000-0000-0000-00000000000b','passport','x');
insert into health_cards(user_id,encrypted_payload) values ('00000000-0000-0000-0000-00000000000b','\x00');
insert into consents(user_id,trip_id,health_shared) values ('00000000-0000-0000-0000-00000000000b','10000000-0000-0000-0000-000000000001',false);
insert into programmes(id,trip_id,created_by,params,status) values ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-00000000000a','{}','draft');

create temp table results(test text, ok boolean);
grant all on results to authenticated;
set role authenticated;
-- as guide
set request.jwt.uid = '00000000-0000-0000-0000-00000000000a';
insert into results select 'guide cannot read documents', (select count(*) from documents) = 0;
insert into results select 'guide cannot read health without consent', (select count(*) from health_cards) = 0;
-- as tourist
set request.jwt.uid = '00000000-0000-0000-0000-00000000000b';
insert into results select 'tourist sees own document', (select count(*) from documents) = 1;
insert into results select 'tourist cannot see draft programme', (select count(*) from programmes) = 0;
insert into results select 'tourist sees only own trip', (select count(*) from trips) = 1;
-- as other
set request.jwt.uid = '00000000-0000-0000-0000-00000000000c';
insert into results select 'other cannot see trip Roma', (select count(*) from trips where name='Roma') = 0;
reset role;
-- consent on, approve
update consents set health_shared = true; update programmes set status = 'approved';
set role authenticated;
set request.jwt.uid = '00000000-0000-0000-0000-00000000000a';
insert into results select 'guide reads health with consent', (select count(*) from health_cards) = 1;
set request.jwt.uid = '00000000-0000-0000-0000-00000000000b';
insert into results select 'tourist sees approved programme', (select count(*) from programmes) = 1;
reset role;
select test, case when ok then 'PASS' else 'FAIL' end from results;
