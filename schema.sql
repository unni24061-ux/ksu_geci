-- KSU GECI backend. Run this whole file in Supabase > SQL Editor.
create table admins(email text primary key);
create table notifications(id bigint generated always as identity primary key,text text not null,created_at timestamptz default now());
create table events(id bigint generated always as identity primary key,title text not null,date date not null,place text,descr text,images text[] default '{}',created_at timestamptz default now());
create table people(id bigint generated always as identity primary key,grp text not null check(grp in('ksu','col')),role text not null,name text,phone text,sort int default 0);
create table helpdesks(slug text primary key,title text,blurb text,body text);
create table settings(key text primary key,value text);
create table complaints(id text primary key,sem text,branch text,name text,phone text,subject text not null,body text not null,anon boolean default false,status text default 'Pending' check(status in('Pending','Under review','Resolved','Rejected')),remark text,created_at timestamptz default now());
create function is_admin() returns boolean language sql security definer stable set search_path=public as $$ select exists(select 1 from admins where email=(auth.jwt()->>'email')) $$;
alter table admins enable row level security;alter table notifications enable row level security;alter table events enable row level security;alter table people enable row level security;alter table helpdesks enable row level security;alter table settings enable row level security;alter table complaints enable row level security;
create policy r on notifications for select using(true);create policy r on events for select using(true);create policy r on people for select using(true);create policy r on helpdesks for select using(true);create policy r on settings for select using(true);
create policy w on notifications for all using(is_admin()) with check(is_admin());create policy w on events for all using(is_admin()) with check(is_admin());create policy w on people for all using(is_admin()) with check(is_admin());create policy w on helpdesks for all using(is_admin()) with check(is_admin());create policy w on settings for all using(is_admin()) with check(is_admin());create policy w on complaints for all using(is_admin()) with check(is_admin());
-- Students never read the complaints table. They only use these two functions.
create function submit_complaint(p_sem text,p_branch text,p_name text,p_phone text,p_subject text,p_body text,p_anon boolean) returns text language plpgsql security definer set search_path=public as $$
declare cid text;begin
 if length(p_subject)>150 or length(p_body)>2000 or length(trim(p_subject))=0 or length(trim(p_body))=0 then raise exception 'invalid complaint';end if;
 cid:='CMP-'||upper(substr(md5(random()::text||clock_timestamp()::text),1,6));
 insert into complaints(id,sem,branch,name,phone,subject,body,anon) values(cid,left(p_sem,10),left(p_branch,20),case when p_anon then 'Anonymous' else nullif(left(p_name,80),'') end,case when p_anon then null else nullif(left(p_phone,20),'') end,p_subject,p_body,p_anon);
 return cid;end $$;
create function track_complaint(cid text) returns table(subject text,status text,remark text,created_at timestamptz) language sql security definer set search_path=public as $$ select c.subject,c.status,c.remark,c.created_at from complaints c where c.id=upper(trim(cid)) $$;
insert into storage.buckets(id,name,public) values('events','events',true) on conflict do nothing;
create policy "events read" on storage.objects for select using(bucket_id='events');
create policy "events admin" on storage.objects for all using(bucket_id='events' and is_admin()) with check(bucket_id='events' and is_admin());
-- Seed data
insert into settings values('wa','919000000000'),('email','ksu.geci@example.com'),('ig','ksu_geci'),('group','');
insert into helpdesks values ('admission','Admission Help Desk','Documents, dates, fees and help','# Documents needed
Allotment memo
SSLC marklist and certificate
Plus Two marklist
Transfer Certificate (TC)
Conduct certificate
Community certificate
Income certificate (if applicable)
Aadhaar card
Passport size photographs
# Dates allotted
CSE | Date to be announced
ECE | Date to be announced
EEE | Date to be announced
ME | Date to be announced
CE | Date to be announced
# Missed reporting date
If you miss your reporting date, contact the admission desk immediately on WhatsApp with your allotment details.
# Fee structure
Tuition fee | To be updated
Caution deposit | To be updated
Other fees | To be updated'),('priyadarshini','Priyadarshini','Dedicated support space','# How can I reach out?
Use the WhatsApp button below and we will get back to you.');
insert into people(grp,role,name,phone,sort) values ('ksu','Chairman','Add name','+91 90000 00001',1),('ksu','Vice Chairman','Add name','+91 90000 00002',2),('ksu','KSU GECI President','Add name','+91 90000 00003',3),('ksu','General Secretary','Add name','+91 90000 00004',4),('ksu','Joint Secretary','Add name','+91 90000 00005',5),('col','Principal','Add name','+91 90000 00011',1),('col','Vice Principal','Add name','+91 90000 00012',2),('col','Office Superintendent','Add name','+91 90000 00013',3),('col','Hostel Warden','Add name','+91 90000 00014',4);
-- After creating your admin user in Authentication > Users, run:
-- insert into admins values('your-email@example.com');
