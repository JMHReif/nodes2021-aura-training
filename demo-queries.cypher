//See the range of dates for payments
MATCH (u:User)-[r:SENDS]->(p:Payment)-[r2:PAID_TO]->(u2:User)
RETURN min(p.dateCreated), max(p.dateCreated);

//Find number of payments for each application
MATCH (p:Payment)-[r:PAID_USING]->(a:Application)
RETURN a.name, count(p) as count
ORDER by count DESC;
 
//Find payment dates for each application
MATCH (p:Payment)-[r:PAID_USING]-(a:Application)
RETURN a.name, count(p) as count, min(p.dateCreated), max(p.dateCreated)
ORDER BY count DESC;
 
//NOTE: tells us a bit about our data set
//https://techcrunch.com/2018/06/15/venmo-is-discontinuing-web-support-for-payments-and-more/

//Find random users who paid other users
MATCH (u:User)-[r:SENDS]->(p:Payment)-[r2:PAID_TO]->(u2:User)
RETURN * LIMIT 30;

//Find users who sent the most payments
MATCH (u:User)-[r:SENDS]-(p:Payment)-[r2:PAID_TO]-(u2:User)
RETURN u.username, count(p) as payments
ORDER BY payments DESC LIMIT 10;

//Find most-payment-user and look at his subgraph
MATCH (u:User {username: 'ConnorDevlin93'})-[r:SENDS]->(p:Payment)-[r2:PAID_TO]->(u2:User)
RETURN u, r, p, r2, u2 LIMIT 30;

//Find 2 users who exchange the most payments
MATCH (u:User)-[r:SENDS]->(p:Payment)-[r2:PAID_TO]->(u2:User)
RETURN u.username, u2.username, count(p) as payments
ORDER BY payments DESC LIMIT 10;

//View graph of 2 users who share most payments between them
MATCH (u:User {username: 'Matthew-Pizzuti'})-[r:SENDS]->(p:Payment)-[r2:PAID_TO]->(u2:User {username: 'michaelm'})
RETURN *;
 
//NOTE: then drill into a payment 
//to see that application is same for all payments and date/time submitted is super close together
 
//See how long users have been sending payments to one another (find long-term friends?)
MATCH (u:User)-[r:SENDS]->(p:Payment)-[r2:PAID_TO]->(u2:User)
WHERE size((u)-[:SENDS]-(:Payment)-[:PAID_TO]-(u2)) > 1
WITH u.username as user1, u2.username as user2, p.dateCreated as payDate ORDER BY p.dateCreated
WITH user1, user2, collect(payDate) as dateList
WITH user1, user2, dateList[0] as first, dateList[-1] as last
RETURN user1, user2, first, last, duration.between(first,last) as duration
ORDER BY duration DESC;