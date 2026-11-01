-- Run this once if you already ran the old schema.sql
delete from helpdesks where slug in('college','hostel');
update helpdesks set title='Admission Help Desk',blurb='Documents, dates, fees and help',body='# Documents needed
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
Other fees | To be updated' where slug='admission';
update helpdesks set title='Priyadarshini',blurb='Dedicated support space',body='# How can I reach out?
Use the WhatsApp button below and we will get back to you.' where slug='priyadarshini';
insert into settings values('group','') on conflict do nothing;
