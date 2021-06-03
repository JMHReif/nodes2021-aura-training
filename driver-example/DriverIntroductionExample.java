import org.neo4j.driver.*;
import org.neo4j.driver.Record;
import org.neo4j.driver.exceptions.Neo4jException;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import static org.neo4j.driver.Config.TrustStrategy.trustAllCertificates;

public class DriverIntroductionExample implements AutoCloseable {
    private static final Logger LOGGER = Logger.getLogger(DriverIntroductionExample.class.getName());
    private final Driver driver;

    public DriverIntroductionExample(String uri, String user, String password, Config config) {
        // The driver is a long living object and should be opened during the start of your application
        driver = GraphDatabase.driver(uri, AuthTokens.basic(user, password), config);
    }

    @Override
    public void close() throws Exception {
        // The driver object should be closed before the application ends.
        driver.close();
    }

    public void createFriendship(final String person1Name, final String person2Name) {
        // To learn more about the Cypher syntax, see https://neo4j.com/docs/cypher-manual/current/
        // The Reference Card is also a good resource for keywords https://neo4j.com/docs/cypher-refcard/current/
        String createFriendshipQuery = "CREATE (p1:Person { name: $person1_name })\n" +
                "CREATE (p2:Person { name: $person2_name })\n" +
                "CREATE (p1)-[:KNOWS]->(p2)\n" +
                "RETURN p1, p2";

        Map<String, Object> params = new HashMap<>();
        params.put("person1_name", person1Name);
        params.put("person2_name", person2Name);

        try (Session session = driver.session()) {
            // Write transactions allow the driver to handle retries and transient errors
            Record record = session.writeTransaction(tx -> {
                Result result = tx.run(createFriendshipQuery, params);
                return result.single();
            });
            System.out.println(String.format("Created friendship between: %s, %s",
                    record.get("p1").get("name").asString(),
                    record.get("p2").get("name").asString()));
        // You should capture any errors along with the query and data for traceability
        } catch (Neo4jException ex) {
            LOGGER.log(Level.SEVERE, createFriendshipQuery + " raised an exception", ex);
            throw ex;
        }
    }

    public void findPerson(final String personName) {
        String readPersonByNameQuery = "MATCH (p:Person)\n" +
                "WHERE p.name = $person_name\n" +
                "RETURN p.name AS name";

        Map<String, Object> params = Collections.singletonMap("person_name", personName);

        try (Session session = driver.session()) {
            Record record = session.readTransaction(tx -> {
                Result result = tx.run(readPersonByNameQuery, params);
                return result.single();
            });
            System.out.println(String.format("Found person: %s", record.get("name").asString()));
        // You should capture any errors along with the query and data for traceability
        } catch (Neo4jException ex) {
            LOGGER.log(Level.SEVERE, readPersonByNameQuery + " raised an exception", ex);
            throw ex;
        }
    }

    public static void main(String... args) throws Exception {
        // Aura queries use an encrypted connection using the "neo4j+s" protocol
        String uri = "<Connect URI for Neo4j Aura database>";

        String user = "<Username for Neo4j Aura database>";
        String password = "<Password for Neo4j Aura database>";

        try (DriverIntroductionExample app = new DriverIntroductionExample(uri, user, password, Config.defaultConfig())) {
            app.createFriendship("Alice", "David");
            app.findPerson("Alice");
        }
    }
}
