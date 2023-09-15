use music_store


/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
select * from employee
order by levels desc
offset 0 rows fetch next 1 row only

select * from employee
where levels in(Select MAX(levels) from employee)


/* Q2: Which countries have the most Invoices? */
select * from invoice A inner join
(Select count(invoice_id) as count_invoices,billing_country from invoice
group by billing_country
order by count_invoices desc
offset 0 rows fetch next 1 row only) B
on A.billing_country=B.billing_country


/* Q3: What are top 3 values of total invoice? */

select distinct top 3 total from invoice
order by total desc   ----- for values

Select sum(total) as ABC, billing_country from invoice
group by billing_country
order by ABC desc
offset 0 rows fetch next 3 row only   ---------- for sum of total according to country

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival 
in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

Select sum(total) as ABC, billing_city from invoice
group by billing_city
order by ABC desc
offset 0 rows fetch next 1 row only



/* Q5: Who is the best customer? The customer who has spent the most money will be declared 
the best customer. 
Write a query that returns the person who has spent the most money.*/
select * from Customer A inner join
(Select sum(total) as Maximum_Spent, customer_id from invoice
group by customer_id) B
on A.customer_id=B.customer_id
order by Maximum_Spent desc
offset 0 row fetch next 1 rows only 



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
Select first_name,last_name,email From customer
where customer_id in
(select customer_id from invoice
where invoice_id in
(select invoice_id from invoice_line
where track_id in
(select Track_id from track
where genre_id in
(select genre_id from genre
where name = 'Rock'))))
order by email


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock 
bands. */
select E.artist_id,F.name,E.[artist sing a song] from Artist F
inner join
(Select D.artist_id, COUNT(*) as 'artist sing a song' from album D
inner join
(Select A.* from track A
inner join
(Select * from genre
where name = 'Rock')B
on A.genre_id= B.genre_id
Where A.genre_id=1)C
on D.album_id=C.album_id
group by D.artist_id) E
on F.artist_id=E.artist_id
order by E.[artist sing a song] desc
offset 0 rows fetch next 10 rows only ---------M1


SELECT top 10 artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC-------------M2



/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest 
songs listed first. */


select * from track
where milliseconds> (select AVG(milliseconds) as a from track) 
order by milliseconds desc


/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, 
artist name and total spent */

Select customer.first_name,sum(invoice_line.unit_price*invoice_line.quantity) as A,artist.name from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.name,customer.first_name
order by A desc



/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular
genre as the genre with the highest amount of purchases. Write a query that returns each country 
along with the top Genre. For countries where the maximum number of purchases is shared return 
all Genres. */



Select genre.genre_id, genre.name,invoice.billing_country, 
ROUND(SUM(invoice_line.quantity*invoice_line.unit_price),2) as Total_spent from genre
join track on genre.genre_id=track.genre_id
join invoice_line on track.track_id=invoice_line.track_id
join invoice on invoice.invoice_id=invoice_line.invoice_id 
group by genre.genre_id, genre.name,invoice.billing_country
order by Total_spent desc 


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


Select * From (select invoice.billing_country,SUM(invoice.total) as Total_spent from invoice
	group by invoice.billing_country) A Right join Customer B on B.country=A.billing_country


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
