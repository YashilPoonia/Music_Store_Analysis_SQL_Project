--Basic Queries
--Ques1 - Who is the senior most employee based on job title?

select * from employee
order by levels desc 
limit 1;


-- Ques2- Which countries have the most Invoices?

select billing_country, 
count(billing_country) 
from invoice
group by billing_country
order by count(billing_country) desc;


--Ques3 - What are top 3 values of total invoice?

select total 
from invoice
order by total desc
limit 3;

--Ques4 - Which city has the highest invoice total?

select billing_city, sum(total) as t
from invoice
group by billing_city
order by t desc
limit 1;

--Ques5 - Who spent most money?
select invoice.customer_id,customer.first_name||' '||customer.last_name as full_name, 
sum(invoice.total) as t
from customer
join invoice
on invoice.customer_id=customer.customer_id
group by invoice.customer_id, customer.first_name, customer.last_name
order by t desc
limit 1
;

--Moderate Queries
--Ques1 - Return email, first name , last name and genre of all Rock music listners.

select distinct t3.customer_id, customer.email, customer.first_name,
customer.last_name, t3.genre from
(select invoice.customer_id,t2.genre from
(select invoice_line.invoice_id, t1.genre 
from (select track_id ,genre from Genre
join track
on genre.genre_Id= track.genre_Id
where genre.name = 'Rock')as t1
join invoice_line
on t1.track_id= invoice_line.track_id
order by t1.track_id) as t2
join invoice
on t2.invoice_id = invoice.invoice_id) as t3
join customer
on t3.customer_id = customer.customer_id
order by customer.email;

--Ques2 -Top 10 Artist name and track count with most rock music.

select artist.name, t2.tracks from
(select album.artist_id, sum(t1.no_of_tracks)as tracks from
  (select track.album_id ,count(track_id)as no_of_tracks from genre
	join track
    on genre.genre_id=track.genre_id
    where genre.name='Rock' group by track.album_id order by track.album_id)as t1
 left join album
on t1.album_id=album.album_id
group by album.artist_id
order by tracks asc ) as t2
 join artist 
 on t2.artist_id=artist.artist_id
 order by t2.tracks desc
 limit 10;


--Ques3 - Names and length of tracks that have length longer than average length.
select track.name,milliseconds from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;


--Advanced queries

/*Ques1-Find how much money is spent by each customer on artists.
Write a query to return customer name, artist name and total spent.*/


with top_artist as
(select artist.artist_id,artist.name,
sum(invoice_line.unit_price*invoice_line.quantity) as money_spent from invoice
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by 1
order by money_spent desc
--limit 1
)


select customer.first_name,customer.last_name,top_artist.name,
sum(invoice_line.unit_price*invoice_line.quantity) as money_spent
from customer 
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join top_artist on top_artist.artist_id = album.artist_id
group by 1,2,3
order by money_spent desc
;

/*Ques2- Return most popular music genre for each country
popular= most sold*/

select * from
(select distinct(customer.country), sum(invoice.total) as most_sold,genre.name
 ,row_number() over (partition by customer.country order by sum(invoice.total) desc)as row_no
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by customer.country, genre.name
order by customer.country)
where row_no <=1
order by most_sold desc
;

/*Ques3 - Find customer who spent most in a country. Return country top customer and 
spending.*/


select * from
(select customer.customer_id,customer.first_name ,customer.last_name ,
customer.country ,sum(invoice.total),
row_number() over(partition by customer.country order by sum(invoice.total) desc)as rn
from customer
join invoice
on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by country)
where rn<=1;
