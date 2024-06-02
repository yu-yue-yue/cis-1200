package org.cis1200;

import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

import java.util.*;

public class ServerModelTest {
    private ServerModel model;

    /**
     * Before each test, we initialize model to be
     * a new ServerModel (with all new, empty state)
     */
    @BeforeEach
    public void setUp() {
        // We initialize a fresh ServerModel for each test
        model = new ServerModel();
    }

    /**
     * Here is an example test that checks the functionality of your
     * changeNickname error handling. Each line has commentary directly above
     * it which you can use as a framework for the remainder of your tests.
     */
    @Test
    public void testInvalidNickname() {
        // A user must be registered before their nickname can be changed,
        // so we first register a user with an arbitrarily chosen id of 0.
        model.registerUser(0);

        // We manually create a Command that appropriately tests the case
        // we are checking. In this case, we create a NicknameCommand whose
        // new Nickname is invalid.
        Command command = new NicknameCommand(0, "User0", "!nv@l!d!");

        // We manually create the expected Broadcast using the Broadcast
        // factory methods. In this case, we create an error Broadcast with
        // our command and an INVALID_NAME error.
        Broadcast expected = Broadcast.error(
                command, ServerResponse.INVALID_NAME
        );

        // We then get the actual Broadcast returned by the method we are
        // trying to test. In this case, we use the updateServerModel method
        // of the NicknameCommand.
        Broadcast actual = command.updateServerModel(model);

        // The first assertEquals call tests whether the method returns
        // the appropriate Broadcast.
        assertEquals(expected, actual, "Broadcast");

        // We also want to test whether the state has been correctly
        // changed.In this case, the state that would be affected is
        // the user's Collection.
        Collection<String> users = model.getRegisteredUsers();

        // We now check to see if our command updated the state
        // appropriately. In this case, we first ensure that no
        // additional users have been added.
        assertEquals(1, users.size(), "Number of registered users");

        // We then check if the username was updated to an invalid value
        // (it should not have been).
        assertTrue(users.contains("User0"), "Old nickname still registered");

        // Finally, we check that the id 0 is still associated with the old,
        // unchanged nickname.
        assertEquals(
                "User0", model.getNickname(0),
                "User with id 0 nickname unchanged"
        );
    }

    /*
     * Your TAs will be manually grading the tests that you write below this
     * comment block. Don't forget to test the public methods you have added to
     * your ServerModel class, as well as the behavior of the server in
     * different scenarios.
     * You might find it helpful to take a look at the tests we have already
     * provided you with in Task4Test, Task3Test, and Task5Test.
     */

    @Test
    public void testRegisterUserAlreadyExists() {
        Broadcast expected0 = Broadcast.connected("User0");
        assertEquals(expected0, model.registerUser(0), "Broadcast for User0");
        Broadcast expected1 = Broadcast.connected("User1");
        assertEquals(expected1, model.registerUser(1), "Broadcast for User1");
        Broadcast expected2 = Broadcast.connected("User2");
        assertEquals(expected2, model.registerUser(1), "Broadcast for User2");

        Collection<String> registeredUsers = model.getRegisteredUsers();
        assertEquals(2, registeredUsers.size(), "Num. registered users");
        assertTrue(registeredUsers.contains("User0"), "User0 is registered");
        assertTrue(registeredUsers.contains("User2"), "User2 is registered");
        // we want it to change the nickname of the user, re-registering them under a different name
    }

    @Test
    public void testReRegisterUser() {
        Broadcast expected0 = Broadcast.connected("User0");
        assertEquals(expected0, model.registerUser(0), "Broadcast for User0");
        Broadcast expected1 = Broadcast.connected("User1");
        assertEquals(expected1, model.registerUser(1), "Broadcast for User1");
        Broadcast expected2 = Broadcast.disconnected("User1", new TreeSet<>());
        assertEquals(expected2, model.deregisterUser(1), "Broadcast for User1 disconnect");
        Broadcast expected3 = Broadcast.connected("User1");
        assertEquals(expected3, model.registerUser(1), "Broadcast for User1 reconnect");

        Collection<String> registeredUsers = model.getRegisteredUsers();
        assertEquals(2, registeredUsers.size(), "Num. registered users");
        assertTrue(registeredUsers.contains("User0"), "User0 is registered");
        assertTrue(registeredUsers.contains("User1"), "User1 is registered");
        // we want it to change the nickname of the user, re-registering them under a different name
    }

    @Test
    public void testDeregisterManyUsers() {
        model.registerUser(0);
        model.registerUser(1);
        Broadcast expected0 = Broadcast.disconnected("User0", new TreeSet<>());
        assertEquals(expected0, model.deregisterUser(0), "Broadcast for User0");
        Broadcast expected1 = Broadcast.disconnected("User1", new TreeSet<>());
        assertEquals(expected1, model.deregisterUser(1), "Broadcast for User1");

        assertTrue(model.getRegisteredUsers().isEmpty(), "Registered users still exist");
    }

    @Test
    public void testDeregisterUsersChannelNotified() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command join = new JoinCommand(1, "User1", "java");
        join.updateServerModel(model);

        Broadcast expected = Broadcast.disconnected("User1",
                new TreeSet<>(Collections.singleton("User0")));
        assertEquals(expected, model.deregisterUser(1), "Broadcast for User1");
        assertTrue(model.getRegisteredUsers().contains("User0"), "Registered user still exist");
        assertEquals(model.getRegisteredUsers().size(), 1, "Registered user still exist");
        assertTrue(model.getChannels().contains("java"), "Channel still exists");
        assertTrue(model.getUsersInChannel("java").contains("User0"),
                "owner still in channel");
        assertTrue(model.getOwner("java").contains("User0"),
                "owner still owns channel");

    }

    @Test
    public void testNickNotInChannels() {
        model.registerUser(0);
        Command command = new NicknameCommand(0, "User0", "cis120");
        Set<String> recipients = Collections.singleton("cis120");
        Broadcast expected = Broadcast.okay(command, recipients);
        assertEquals(expected, command.updateServerModel(model), "Broadcast");
        Collection<String> users = model.getRegisteredUsers();
        assertFalse(users.contains("User0"), "Old nick not registered");
        assertTrue(users.contains("cis120"), "New nick registered");
    }

    @Test
    public void testCreateNewChannelExists() {
        model.registerUser(0);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command createAgain = new CreateCommand(0, "User0", "java", false);
        Broadcast expected = Broadcast.error(createAgain, ServerResponse.CHANNEL_ALREADY_EXISTS);
        assertEquals(expected, createAgain.updateServerModel(model), "broadcast");

        assertTrue(model.getChannels().contains("java"), "channel exists");
        assertTrue(
                model.getUsersInChannel("java").contains("User0"),
                "channel has creator"
        );
        assertEquals("User0", model.getOwner("java"), "channel has owner");
    }

    @Test
    public void testCreatePrivateChannel() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", true);
        Broadcast expected = Broadcast.okay(create, Collections.singleton("User0"));
        assertEquals(expected, create.updateServerModel(model), "broadcast");

        assertTrue(model.getChannels().contains("java"), "channel exists");
        assertTrue(
                model.getUsersInChannel("java").contains("User0"),
                "channel has creator"
        );
        assertEquals("User0", model.getOwner("java"), "channel has owner");
        Command join = new JoinCommand(1, "User1", "java");
        Broadcast expectedFail = Broadcast.error(join, ServerResponse.JOIN_PRIVATE_CHANNEL);
        assertEquals(join.updateServerModel(model), expectedFail);
        assertEquals(model.getUsersInChannel("java").size(), 1, "one user in channel");
        assertEquals(model.getRegisteredUsers().size(), 2, "both users in server");
    }

    @Test
    public void testDeregisterOwnerOfChannel() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command join = new JoinCommand(1, "User1", "java");
        join.updateServerModel(model);

        Broadcast expected = Broadcast.disconnected("User0",
                new TreeSet<>(Collections.singleton("User1")));
        assertEquals(expected, model.deregisterUser(0), "Broadcast for User0");
        assertTrue(model.getRegisteredUsers().contains("User1"), "Registered user still exists");
        assertEquals(model.getRegisteredUsers().size(), 1, "Registered user still exists");
        assertTrue(model.getChannels().isEmpty(), "Channel doesn't exist");
        assertTrue(model.getUsersInChannel("java").isEmpty());

    }

    @Test
    public void testCreateNewChannelExistsDifferentOwners() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command createAgain = new CreateCommand(1, "User1", "java", false);
        Broadcast expected = Broadcast.error(createAgain, ServerResponse.CHANNEL_ALREADY_EXISTS);
        assertEquals(expected, createAgain.updateServerModel(model), "broadcast");

        assertTrue(model.getChannels().contains("java"), "channel exists");
        assertTrue(
                model.getUsersInChannel("java").contains("User0"),
                "channel has creator"
        );
        assertEquals("User0", model.getOwner("java"), "channel has owner");
    }

    @Test
    public void testJoinChannel() {
        model.registerUser(0);
        model.registerUser(1);
        CreateCommand create = new CreateCommand(0, "User0", "java", false);
        model.createChannel(create);
        JoinCommand join = new JoinCommand(1, "User1", "java");
        model.joinChannel(join);

        assertTrue(
                model.getUsersInChannel("java").contains("User0"),
                "User0 in channel"
        );
        assertTrue(
                model.getUsersInChannel("java").contains("User1"),
                "User1 in channel"
        );
        assertEquals(
                2, model.getUsersInChannel("java").size(),
                "num. users in channel"
        );
    }

    @Test
    public void testJoinChannelExistsAlreadyMember() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);

        Command join = new JoinCommand(1, "User1", "java");
        join.updateServerModel(model);
        Command joinAgain = new JoinCommand(1, "User1", "java");
        joinAgain.updateServerModel(model);
        Set<String> recipients = new TreeSet<>();
        recipients.add("User1");
        recipients.add("User0");
        Broadcast expected = Broadcast.names(join, recipients, "User0");
        assertEquals(expected, join.updateServerModel(model), "broadcast");

        assertTrue(
                model.getUsersInChannel("java").contains("User0"),
                "User0 in channel"
        );
        assertTrue(
                model.getUsersInChannel("java").contains("User1"),
                "User1 in channel"
        );
        assertEquals(
                2, model.getUsersInChannel("java").size(),
                "num. users in channel"
        );
    }

    @Test
    public void testLeaveChannelNotMember() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);

        Command leave = new LeaveCommand(1, "User1", "java");
        Broadcast expected = Broadcast.error(leave, ServerResponse.USER_NOT_IN_CHANNEL);
        assertEquals(expected, leave.updateServerModel(model), "broadcast");

        assertTrue(
                model.getUsersInChannel("java").contains("User0"),
                "User0 in channel"
        );
        assertFalse(
                model.getUsersInChannel("java").contains("User1"),
                "User1 not in channel"
        );
        assertEquals(
                1, model.getUsersInChannel("java").size(),
                "num. users in channel"
        );
    }

    @Test
    public void testLeaveOwnerOfChannel() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command join = new JoinCommand(1, "User1", "java");
        join.updateServerModel(model);
        Command leave = new LeaveCommand(0, "User0", "java");

        Collection<String> recipients = new TreeSet<>();
        recipients.add("User0");
        recipients.add("User1");

        Broadcast expected = Broadcast.okay(leave, recipients);
        assertEquals(expected, leave.updateServerModel(model), "Broadcast for User0");
        assertTrue(model.getRegisteredUsers().contains("User1"), "Registered user still exists");
        assertTrue(model.getRegisteredUsers().contains("User0"), "Registered user still exists");
        assertEquals(model.getRegisteredUsers().size(), 2, "Registered user still exists");
        assertTrue(model.getChannels().isEmpty(), "Channel doesn't exist");
        assertTrue(model.getUsersInChannel("java").isEmpty());

    }


    @Test
    public void testMesgChannelNotMember() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command join = new JoinCommand(1, "User1", "java");
        join.updateServerModel(model);

        Command mesg = new MessageCommand(2, "User2", "java", "hey whats up hello");
        Broadcast expected = Broadcast.error(mesg, ServerResponse.USER_NOT_IN_CHANNEL);
        assertEquals(expected, mesg.updateServerModel(model), "broadcast");
    }

    @Test
    public void testMesgChannelNoChannel() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);
        Command join = new JoinCommand(1, "User1", "java");
        join.updateServerModel(model);

        Command mesg = new MessageCommand(1, "User1", "python", "hey whats up hello");
        Broadcast expected = Broadcast.error(mesg, ServerResponse.NO_SUCH_CHANNEL);
        assertEquals(expected, mesg.updateServerModel(model), "broadcast");
    }

    @Test
    public void testMesgChannelSingleUser() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", false);
        create.updateServerModel(model);

        Command mesg = new MessageCommand(0, "User0", "java", "hey whats up hello");
        Set<String> recipients = new TreeSet<>();
        recipients.add("User0");
        Broadcast expected = Broadcast.okay(mesg, recipients);
        assertEquals(expected, mesg.updateServerModel(model), "broadcast");

    }


    @Test
    public void testInviteByOwner() {
        model.registerUser(0); // add user with id = 0
        model.registerUser(1); // add user with id = 1
        model.registerUser(2); // add user with id = 2
        model.registerUser(3); // add user with id = 3

        // this command will create a channel called "java" with "User0" (with id = 0)
        // as the owner
        Command create = new CreateCommand(0, "User0", "java", true);

        // this line *actually* updates the model's state
        create.updateServerModel(model);
        Command invite1 = new InviteCommand(0, "User0", "java", "User1");
        Command invite2 = new InviteCommand(0, "User0", "java", "User2");
        invite1.updateServerModel(model);
        invite2.updateServerModel(model);

        assertEquals(3, model.getUsersInChannel("java").size(), "num. users in channel");
        assertTrue(model.getUsersInChannel("java").contains("User0"), "User0 in channel");
        assertTrue(model.getUsersInChannel("java").contains("User1"), "User1 in channel");
        assertTrue(model.getUsersInChannel("java").contains("User2"), "User2 in channel");
        assertEquals(model.getRegisteredUsers().size(), 4, "all 4 users registered");
    }

    @Test
    public void testKickMultipleChannels() {
        model.registerUser(0); // add user with id = 0
        model.registerUser(1); // add user with id = 1

        // this command will create a channel called "java" with "User0" (with id = 0)
        // as the owner
        Command create1 = new CreateCommand(0, "User0", "java", true);
        Command create2 = new CreateCommand(0, "User0", "python", true);

        Command invite1 = new InviteCommand(0, "User0", "java", "User1");
        Command invite2 = new InviteCommand(0, "User0", "python", "User1");
        // this line *actually* updates the model's state
        create1.updateServerModel(model);
        create2.updateServerModel(model);
        invite1.updateServerModel(model);
        invite2.updateServerModel(model);

        Command kick = new KickCommand(0, "User0", "java", "User1");
        Set<String> recipients = new TreeSet<>();
        recipients.add("User1");
        recipients.add("User0");
        Broadcast expected = Broadcast.okay(kick, recipients);
        assertEquals(expected, kick.updateServerModel(model));

        assertEquals(2, model.getUsersInChannel("python").size(), "num. users in channel");
        assertTrue(model.getUsersInChannel("python").contains("User0"), "User0 still in channel");
        assertTrue(model.getUsersInChannel("python").contains("User1"), "User1 still in channel");
    }

    @Test
    public void testKickUserNotInChannel() {
        model.registerUser(0); // add user with id = 0
        model.registerUser(1); // add user with id = 1

        // this command will create a channel called "java" with "User0" (with id = 0)
        // as the owner
        Command create = new CreateCommand(0, "User0", "java", true);
        create.updateServerModel(model);
        Command kick = new KickCommand(0, "User0", "java", "User1");

        Broadcast expected = Broadcast.error(kick, ServerResponse.USER_NOT_IN_CHANNEL);
        assertEquals(expected, kick.updateServerModel(model));

        assertEquals(1, model.getUsersInChannel("java").size(), "num. users in channel");
        assertTrue(model.getUsersInChannel("java").contains("User0"), "User0 still in channel");
    }
    @Test
    public void testKickUserChannelDNE() {
        model.registerUser(0); // add user with id = 0
        Command create = new CreateCommand(0, "User0", "java", true);
        create.updateServerModel(model);
        Command kick = new KickCommand(0, "User0", "python", "User0");
        Broadcast expected = Broadcast.error(kick, ServerResponse.NO_SUCH_CHANNEL);
        assertEquals(expected, kick.updateServerModel(model));

        assertEquals(1, model.getUsersInChannel("java").size(), "num. users in channel");
        assertTrue(model.getUsersInChannel("java").contains("User0"), "User0 still in channel");
    }

    @Test
    public void testKickUserDNE() {
        model.registerUser(0); // add user with id = 0
        Command create = new CreateCommand(0, "User0", "java", true);
        create.updateServerModel(model);
        Command kick = new KickCommand(0, "User0", "java", "User1");
        Broadcast expected = Broadcast.error(kick, ServerResponse.NO_SUCH_USER);
        assertEquals(expected, kick.updateServerModel(model));

        assertEquals(1, model.getUsersInChannel("java").size(), "num. users in channel");
        assertTrue(model.getUsersInChannel("java").contains("User0"), "User0 still in channel");
    }

    @Test
    public void testKickUserNotOwner() {
        model.registerUser(0); // add user with id = 0
        model.registerUser(1); // add user with id = 1

        // this command will create a channel called "java" with "User0" (with id = 0)
        // as the owner
        Command create = new CreateCommand(0, "User0", "java", true);
        create.updateServerModel(model);
        Command invite = new InviteCommand(0, "User0", "java", "User1");
        invite.updateServerModel(model);
        Command kick = new KickCommand(1, "User1", "java", "User0");
        Set<String> recipients = new TreeSet<>();
        recipients.add("User1");
        recipients.add("User0");
        Broadcast expected = Broadcast.error(kick, ServerResponse.USER_NOT_OWNER);
        assertEquals(expected, kick.updateServerModel(model));

        assertEquals(2, model.getUsersInChannel("java").size(), "num. users in channel");
        assertTrue(model.getUsersInChannel("java").contains("User0"), "User0 still in channel");
    }

    @Test
    public void testKickOwnerOfChannel() {
        model.registerUser(0);
        model.registerUser(1);
        Command create = new CreateCommand(0, "User0", "java", true);
        create.updateServerModel(model);
        Command invite = new InviteCommand(0, "User0", "java", "User1");
        invite.updateServerModel(model);
        Command kick = new KickCommand(0, "User0", "java", "User0");

        Collection<String> recipients = new TreeSet<>();
        recipients.add("User0");
        recipients.add("User1");

        Broadcast expected = Broadcast.okay(kick, recipients);
        assertEquals(expected, kick.updateServerModel(model), "Broadcast for User0");
        assertTrue(model.getRegisteredUsers().contains("User1"), "Registered user still exists");
        assertTrue(model.getRegisteredUsers().contains("User0"), "Registered user still exists");
        assertEquals(model.getRegisteredUsers().size(), 2, "Registered user still exists");
        assertTrue(model.getChannels().isEmpty(), "Channel doesn't exist");
        assertTrue(model.getUsersInChannel("java").isEmpty());

    }


}
