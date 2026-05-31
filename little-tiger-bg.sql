
create table plan(
	id SERIAL PRIMARY KEY,
	name varchar(100) unique not null (length(name) >= 5),
	pricing numeric(10,2) default 0.00
-- plan subscriptions are owned by a plan
);

create table subscription(
	id serial primary key,
	created_At date default now(),
	updated_At date default now(),
	
-- user can activate and disable subscription, so it does make sense to keep track of when it ends
-- and when it started as well as when it was "cancelled"
	dt_subscribed date default now(),
	dt_unsubscribed date default null,
	active boolean not null default true,
	
-- subscription plan could and maybe should be a separate entity, guarding pricing and capabilites of such subscription
-- however in case of a discount this subscription would house pricing as well
	pricing numeric(10,2) default 0.00
);

create table reader (
	id serial primary key,
	email varchar(100) unique not null (length(email) >= 100),
	password varchar(100) not null (length(name) >= 8),
	
	dob date not null, 	
	age int,
-- country defined through a fixed char, bound by regex to items such as US, BR, UK, etc.
	country_code char(2) not null check (country_code ~ '^[A-Z]{2}$') default 'BR',
	
	first_name varchar(50) not null,
    last_name varchar(50) not null,
    full_name varchar(101) generated always as (first_name || ' ' || last_name) STORED
);

create type degree_type as enum ('doctors', 'masters', 'post-graduate', 'graduate');

create table academic_degree(
	id int primary key,
	institution varchar(100),
	degree degree_type
);

-- would author be an user as well, publishing articles and all
create table author (
	id serial primary key,
	
	first_name varchar(50) not null,
    last_name varchar(50) not null,
    full_name varchar(101) generated always as (first_name || ' ' || last_name) stored,
    
	email varchar(100) unique  not null,
	dob date,
	work_area varchar(50),
	
	country_code char(2) check (country_code ~ '^[A-Z]{2}$')
);


create type billing_cycle_type as enum ('anual', 'monthly','one_time_purchase');

alter table plan add column billing_cycle billing_cycle_type default 'monthly';

create table publisher(
	id serial primary key,
    legal_name varchar(100) NOT NULL,
    web_site varchar(200),
	country_code char(2) check (country_code ~ '^[A-Z]{2}$') default 'BR'
);


create table category(
	id serial primary key,
	name varchar(100),
	description text
);

create table title (
	id serial primary key,
	isbn_doi varchar(255),
	dt_published date not null,
	
	title varchar(255),
    sinopsis text,
    lang char(5) not null default 'pt_BR',
    
    n_pages INT NOT NULL CHECK (n_pages > 0),
    
    public_access BOOLEAN NOT NULL DEFAULT false
);

create table book(
	edition SMALLINT,
    type varchar(50)
) inherits(title);

create table article(
	published_journal varchar(300),
    volume varchar(20),
    edition_number varchar(20)
) inherits(title);


-- Relationship Def

-- 1-N
-- reader-subcription
ALTER TABLE subscription
ADD COLUMN reader_id int references reader(id) on delete cascade;

-- plan-subcription
alter table subscription
add column plan_id int references plan(id) on delete cascade;

-- publisher-title
alter table title
add column publisher_id int references publisher(id) on delete cascade;

-- N-N (tables)
-- author-title
create table author_title(
	author_id int references author(id) on delete cascade,
	title_id int references title(id) on delete cascade,
	primary key (author_id, title_id)
);
-- plan-publisher
create table plan_publisher(
	plan_id int references plan(id) on delete cascade,
	publisher_id int references publisher(id) on delete cascade,
	primary key (plan_id, publisher_id)
);
-- category-title
create table category_title(
	category_id int references category(id) on delete cascade,
	title_id int references title(id) on delete cascade,
	primary key (category_id, title_id)
);
-- reader-title (progress, review, wishlist)

create table reader_wishlist(
	dt_creation date default now(),
	priority_order int not null,
	
	reader_id int references reader(id) on delete cascade,
	title_id int references title(id) on delete cascade,
	primary key (reader_id, title_id)
);

create table reader_progress(
	current_page int,
	updated_at date default now(),
	
	reader_id int references reader(id) on delete cascade,
	title_id int references title(id) on delete cascade,
	primary key (reader_id, title_id)
);

create table reader_review(
	commentary text,
	dt_creation date default now(),
	-- delimits range from 1-5
	score SMALLINT not null check  (score between 1 and 5),

	reader_id int references reader(id) on delete cascade,
	title_id int references title(id) on delete cascade,
	primary key (reader_id, title_id)
);

create table author_degree (
    author_id int references author(id) on delete cascade,
    degree_id int references academic_degree(id) on delete cascade,
    primary key (author_id, degree_id)
);

