
/* QUESTIONS 
 Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do.
*/

SELECT * FROM Facilities F WHERE membercost = 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) FROM Facilities WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, f.monthlymaintenance FROM Facilities f WHERE f.membercost < 0.2*f.monthlymaintenance;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities f WHERE f.facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT CASE WHEN f.monthlymaintenance < 100 THEN 'Cheap'
						WHEN f.monthlymaintenance >= 100 THEN 'Expensive'
            ELSE 'Error' END AS cheap_costly, f.name, f.monthlymaintenance
FROM Facilities f


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT m.firstname, m.surname
FROM Members m
WHERE m.joindate LIKE '%2012-09-26%';

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT m.firstname || ' ' || m.surname, f.name
FROM Members m
JOIN Bookings b ON b.memid = m.memid
JOIN Facilities f ON f.facid = b.facid 
WHERE LOWER(f.name) LIKE '%tennis%'
ORDER BY 1;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, m.firstname || ' ' || m.surname, b.slots * f.membercost AS Member_Cost, b.slots * f.guestcost AS Guest_Cost
FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
JOIN Members m ON m.memid = b.memid
WHERE b.starttime LIKE ('%2012-09-14%') AND (Guest_Cost > 30 OR Member_Cost > 30)
ORDER BY 3 DESC,4 DESC;



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

WITH cost AS (
  SELECT b.memid, f.name AS Facility, b.slots * f.membercost AS Member_Cost, b.slots * f.guestcost AS Guest_Cost
  FROM Bookings b 
  LEFT JOIN Facilities f ON f.facid = b.facid
  WHERE b.starttime LIKE ('%2012-09-14%'))
SELECT m.firstname || ' ' || m.surname AS Name, Facility, Member_Cost, Guest_Cost
FROM Members m 
JOIN cost c ON m.memid = c.memid
WHERE Member_Cost > 30 OR Guest_Cost > 30


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

WITH FacilityRevenue AS (
    SELECT f.facid, f.name, (f.membercost * b.slots) + (f.guestcost * b.slots) AS Revenue
    FROM Facilities f
    LEFT JOIN Bookings b ON f.facid = b.facid
)
SELECT facid, name, Revenue
FROM FacilityRevenue
WHERE Revenue < 1000
ORDER BY Revenue DESC;

SELECT b.facid, f.name, COUNT(*) AS booking_count
FROM Bookings b
LEFT JOIN Facilities f ON f.facid = b.facid
GROUP BY b.facid, f.name;


SELECT f.facid, f.name, SUM((f.membercost * b.slots) + (f.guestcost * b.slots)) AS revenue
FROM Bookings b
LEFT JOIN Facilities f ON f.facid = b.facid
GROUP BY f.facid, f.name
HAVING revenue < 1000
ORDER BY revenue DESC;


SELECT f.facid, f.name, SUM((f.membercost * b.slots) + (f.guestcost * b.slots)) AS revenue
FROM Bookings b
LEFT JOIN Facilities f ON f.facid = b.facid
GROUP BY f.facid, f.name
ORDER BY revenue DESC;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT DISTINCT m.surname || ' ' || m.firstname AS member_name, m1.surname || ' ' || m1.firstname AS recommender_name
FROM Members m
JOIN Members m1 ON m.recommendedby = m1.memid
ORDER BY m.surname, m.firstname;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name AS facility_name, 
       SUM(CASE WHEN b.memid != 0 THEN b.slots ELSE 0 END) AS member_usage
FROM Facilities f
LEFT JOIN Bookings b ON f.facid = b.facid
GROUP BY f.facid, f.name;

/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name AS facility_name, 
       SUM(CASE WHEN b.memid != 0 THEN b.slots ELSE 0 END) AS member_usage,
       strftime('%m', b.starttime) AS Month
FROM Facilities f
LEFT JOIN Bookings b ON f.facid = b.facid
GROUP BY f.name, Month
ORDER BY Month;


