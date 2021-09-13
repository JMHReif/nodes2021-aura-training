CREATE CONSTRAINT IF NOT EXISTS ON (a:Application) ASSERT a.applicationId IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS ON (a:Application) ASSERT a.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS ON (p:Payment) ASSERT p.paymentId IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS ON (u:User) ASSERT u.userId IS UNIQUE;

//Create Applications, Payments and connect with relationship
WITH 'https://raw.githubusercontent.com/JMHReif/nodes2021-aura-training/main/venmo_demo.csv' as file
LOAD CSV WITH HEADERS FROM file AS line
MERGE (app:Application {applicationId: line.`app.id`})
ON CREATE SET app.name = line.`app.name`, app.description = line.`app.description`, app.imageURL = line.`app.image_url`
WITH line, app
MERGE (pay:Payment {paymentId: line.`payment.id`})
ON CREATE SET pay.audience = line.audience, pay.dateCreated = datetime(line.`payment.date_created`), pay.status = line.`payment.status`, pay.note = line.`payment.note`, pay.action = line.`payment.action`, pay.type = line.type, pay.dateComplete = CASE WHEN coalesce(line.`payment.date_completed`,"") = "" THEN null ELSE datetime(line.`payment.date_completed`) END
WITH line, app, pay
MERGE (pay)-[r2:PAID_USING]->(app)
RETURN count(*);

//Create paying User, find loaded Payment and connect with relationship
WITH 'https://raw.githubusercontent.com/JMHReif/nodes2021-aura-training/main/venmo_demo.csv' as file
LOAD CSV WITH HEADERS FROM file AS line
MERGE (from:User {userId: line.`payment.actor.id`})
ON CREATE SET from.isBlocked = line.`payment.actor.is_blocked`, from.dateJoined = datetime(line.`payment.actor.date_joined`), from.about = line.`payment.actor.about`, from.displayName = line.`payment.actor.display_name`, from.firstName = line.`payment.actor.firstName`, from.lastName = line.`payment.actor.last_name`, from.profilePicURL = line.`payment.actor.profile_picture_url`, from.isGroup = line.`payment.actor.is_group`, from.username = line.`payment.actor.username`
WITH line, from
MATCH (pay:Payment {paymentId: line.`payment.id`})
MERGE (from)-[r:SENDS]->(pay)
RETURN count(*);

//Create paid User, find loaded Payment and connect with relationship
WITH 'https://raw.githubusercontent.com/JMHReif/nodes2021-aura-training/main/venmo_demo.csv' as file
LOAD CSV WITH HEADERS FROM file AS line
MERGE (to:User {userId: coalesce(line.`payment.target.user.id`, 'unknown')})
ON CREATE SET to.firstName = line.`payment.target.user.first_name`, to.dateJoined = CASE WHEN coalesce(line.`payment.target.user.date_joined`,"") = "" THEN null ELSE datetime(line.`payment.target.user.date_joined`) END, to.isGroup = line.`payment.target.user.is_group`, to.lastName = line.`payment.target.user.last_name`, to.isActive = line.`payment.target.user.is_active`, to.isBlocked = line.`payment.target.user.is_blocked`, to.profilePicURL = line.`payment.target.user.profile_picture_url`, to.about = line.`payment.target.user.about`, to.username = line.`payment.target.user.username`, to.displayName = line.`payment.target.user.display_name`
WITH line, to
MATCH (pay:Payment {paymentId: line.`payment.id`})
MERGE (pay)-[r3:PAID_TO]->(to)
RETURN count(*);
