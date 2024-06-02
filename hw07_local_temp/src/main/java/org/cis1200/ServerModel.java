package org.cis1200;

import java.util.*;

/*
 * Make sure to write your own tests in ServerModelTest.java.
 * The tests we provide for each task are NOT comprehensive!
 */

/**
 * The {@code ServerModel} is the class responsible for tracking the
 * state of the server, including its current users and the channels
 * they are in.
 * This class is used by subclasses of {@link Command} to:
 * 1. handle commands from clients, and
 * 2. handle commands from {@link ServerBackend} to coordinate
 * client connection/disconnection.
 */
public final class ServerModel {

    private TreeMap<Integer, String> users;

    private LinkedList<Channel> channels;

    /**
     * Constructs a {@code ServerModel}. Make sure to initialize any collections
     * used to model the server state here.
     */
    public ServerModel() {
        users = new TreeMap<>();
        channels = new LinkedList<>();

    }

    // =========================================================================
    // == Task 2: Basic Server model queries
    // == These functions provide helpful ways to test the state of your model.
    // == You may also use them in later tasks.
    // =========================================================================

    /**
     * Gets the user ID currently associated with the given
     * nickname. The returned ID is -1 if the nickname is not
     * currently in use.
     *
     * @param nickname The nickname for which to get the associated user ID
     * @return The user ID of the user with the argued nickname if
     *         such a user exists, otherwise -1
     */
    public int getUserId(String nickname) {
        if (nickname == null) {
            return -1;
        }
        if (users.containsValue(nickname)) {
            Set<Map.Entry<Integer, String>> userIDEntrySet = users.entrySet();
            for (Map.Entry<Integer, String> currentEntry: userIDEntrySet) {
                if (currentEntry.getValue().equals(nickname)) {
                    return currentEntry.getKey();
                }
            }
        }
        return -1;
    }

    /**
     * Gets the nickname currently associated with the given user
     * ID. The returned nickname is null if the user ID is not
     * currently in use.
     *
     * @param userId The user ID for which to get the associated
     *               nickname
     * @return The nickname of the user with the argued user ID if
     *         such a user exists, otherwise null
     */
    public String getNickname(int userId) {
        if (users.containsKey(userId)) {
            Set<Map.Entry<Integer, String>> userIDEntrySet = users.entrySet();
            for (Map.Entry<Integer, String> currentEntry: userIDEntrySet) {
                if (currentEntry.getKey().equals(userId)) {
                    return currentEntry.getValue();
                }
            }
        }
        return null;
    }

    /**
     * Gets a collection of the nicknames of all users who are
     * registered with the server. Changes to the returned collection
     * should not affect the server state.
     * 
     * This method is provided for testing.
     *
     * @return The collection of registered user nicknames
     */
    public Collection<String> getRegisteredUsers() {
        Set<String> registeredUsers = new TreeSet<>();
        Set<Map.Entry<Integer, String>> userIDEntrySet = users.entrySet();
        for (Map.Entry<Integer, String> currentEntry: userIDEntrySet) {
            registeredUsers.add(currentEntry.getValue());
        }

        return registeredUsers;
    }

    /**
     * Gets a collection of the names of all the channels that are
     * present on the server. Changes to the returned collection
     * should not affect the server state.
     * 
     * This method is provided for testing.
     *
     * @return The collection of channel names
     */
    public Collection<String> getChannels() {
        List<String> channelNames = new LinkedList<>();
        for (Channel c: channels) {
            channelNames.add(c.getChannelName());
        }
        return channelNames;
    }

    /**
     * Gets a collection of the nicknames of all the users in a given
     * channel. The collection is empty if no channel with the given
     * name exists. Modifications to the returned collection should
     * not affect the server state.
     *
     * This method is provided for testing.
     *
     * @param channelName The channel for which to get member nicknames
     * @return A collection of all user nicknames in the channel
     */
    public Collection<String> getUsersInChannel(String channelName) {
        List<String> channelUsers = new LinkedList<>();
        for (Channel c: channels) {
            if (c.getChannelName().equals(channelName)) {
                for (Integer user: c.getUsers()) {
                    channelUsers.add(users.get(user));
                }
            }

        }
        return channelUsers;
    }

    /**
     * Gets the nickname of the owner of the given channel. The result
     * is {@code null} if no channel with the given name exists.
     *
     * This method is provided for testing.
     *
     * @param channelName The channel for which to get the owner nickname
     * @return The nickname of the channel owner if such a channel
     *         exists; otherwise, return null
     */
    public String getOwner(String channelName) {
        Channel c = findChannel(channelName);
        if (c == null) {
            return null;
        } else {
            return getNickname(c.getOwner());
        }
    }

    // ===============================================
    // == Task 3: Connections and Setting Nicknames ==
    // ===============================================

    /**
     * This method is automatically called by the backend when a new client
     * connects to the server. It should generate a default nickname with
     * {@link #generateUniqueNickname()}, store the new user's ID and username
     * in your data structures for {@link ServerModel} state, and construct
     * and return a {@link Broadcast} object using
     * {@link Broadcast#connected(String)}}.
     *
     * @param userId The new user's unique ID (automatically created by the
     *               backend)
     * @return The {@link Broadcast} object generated by calling
     *         {@link Broadcast#connected(String)} with the proper parameter
     */
    public Broadcast registerUser(int userId) {
        String nickname = generateUniqueNickname();
        // We have taken care of generating the nickname and returning
        // the Broadcast for you. You need to modify this method to
        // store the new user's ID and username in this model's internal state.
        users.put(userId, nickname);
        return Broadcast.connected(nickname);
    }

    /**
     * Helper for {@link #registerUser(int)}. (Nothing to do here.)
     *
     * Generates a unique nickname of the form "UserX", where X is the
     * smallest non-negative integer that yields a unique nickname for a user.
     * 
     * @return The generated nickname
     */
    private String generateUniqueNickname() {
        int suffix = 0;
        String nickname;
        Collection<String> existingUsers = getRegisteredUsers();
        do {
            nickname = "User" + suffix++;
        } while (existingUsers.contains(nickname));
        return nickname;
    }

    /**
     * A helper method that returns all the channels a user is in
     * @param userID: the user's ID
     * @return the channels the user is currently in
     */
    private LinkedList<Channel> channelsIn(int userID) {
        LinkedList<Channel> cs = new LinkedList<>();
        for (Channel c: channels) {
            if (c.getUsers().contains(userID)) {
                cs.add(c);
            }
        }
        return cs;
    }

    /**
     * finds all the people in the channels a given user is in
     * @param userID The user's ID
     * @return all the user's "friends", people who they share a channel with
     */
    private Set<String> friends(int userID) {
        LinkedList<Channel> channelsIn = channelsIn(userID);
        Set<String> friends = new TreeSet<>();

        for (Channel c: channelsIn) {
            for (Integer friend: c.getUsers()) {
                friends.add(getNickname(friend));
            }
        }
        return friends;

    }

    /**
     * This method is automatically called by the backend when a client
     * disconnects from the server. This method should take the following
     * actions, not necessarily in this order:
     *
     * (1) All users who shared a channel with the disconnected user should be
     * notified that they left
     * (2) All channels owned by the disconnected user should be deleted
     * (3) The disconnected user's information should be removed from
     * {@link ServerModel}'s internal state
     * (4) Construct and return a {@link Broadcast} object using
     * {@link Broadcast#disconnected(String, Collection)}.
     *
     * @param userId The unique ID of the user to deregister
     * @return The {@link Broadcast} object generated by calling
     *         {@link Broadcast#disconnected(String, Collection)} with the proper
     *         parameters
     */
    public Broadcast deregisterUser(int userId) {
        LinkedList<Channel> channelsIn = channelsIn(userId);
        LinkedList<Channel> channelsOwned = new LinkedList<>();
        Set<String> friends = friends(userId);
        String nickname = getNickname(userId);

        for (Channel c: channelsIn) {
            if (c.getOwner().equals(userId)) {
                channelsOwned.add(c);
            }
        }

        for (Channel c: channelsIn) {
            c.removeUser(userId);
        }

        for (Channel c: channelsOwned) {
            channels.remove(c);
        }

        users.remove(userId);
        if (!friends.isEmpty()) {
            friends.remove(nickname);
        }

        return Broadcast.disconnected(nickname, friends);
    }

    /**
     * This method is called when a user wants to change their nickname.
     * 
     * @param nickCommand The {@link NicknameCommand} object containing
     *                    all information needed to attempt a nickname change
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#okay(Command, Collection)} if the nickname
     *         change is successful. The command should be the original nickCommand
     *         and the collection of recipients should be any clients who
     *         share at least one channel with the sender, including the sender.
     *
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#INVALID_NAME} if the proposed nickname
     *         is not valid according to
     *         {@link ServerModel#isValidName(String)}
     *         (2) {@link ServerResponse#NAME_ALREADY_IN_USE} if there is
     *         already a user with the proposed nickname
     */
    public Broadcast changeNickname(NicknameCommand nickCommand) {
        String newNick = nickCommand.getNewNickname();
        if (!isValidName(newNick)) {
            return Broadcast.error(nickCommand, ServerResponse.INVALID_NAME);
        }

        for (String name: getRegisteredUsers()) {
            if (name.equals(newNick)) {
                return Broadcast.error(nickCommand, ServerResponse.NAME_ALREADY_IN_USE);
            }
        }

        users.put(nickCommand.getSenderId(), newNick);
        return Broadcast.okay(nickCommand, friends(nickCommand.getSenderId()));
    }

    /**
     * Determines if a given nickname is valid or invalid (contains at least
     * one alphanumeric character, and no non-alphanumeric characters).
     * (Nothing to do here.)
     * 
     * @param name The channel or nickname string to validate
     * @return true if the string is a valid name
     */
    public static boolean isValidName(String name) {
        if (name == null || name.isEmpty()) {
            return false;
        }
        for (char c : name.toCharArray()) {
            if (!Character.isLetterOrDigit(c)) {
                return false;
            }
        }
        return true;
    }

    // ===================================
    // == Task 4: Channels and Messages ==
    // ===================================

    /**
     * This method is called when a user wants to create a channel.
     * You can ignore the privacy aspect of this method for task 4, but
     * make sure you come back and implement it in task 5.
     * 
     * @param createCommand The {@link CreateCommand} object containing all
     *                      information needed to attempt channel creation
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#okay(Command, Collection)} if the channel
     *         creation is successful. The only recipient should be the new
     *         channel's owner.
     *
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#INVALID_NAME} if the proposed
     *         channel name is not valid according to
     *         {@link ServerModel#isValidName(String)}
     *         (2) {@link ServerResponse#CHANNEL_ALREADY_EXISTS} if there is
     *         already a channel with the proposed name
     */
    public Broadcast createChannel(CreateCommand createCommand) {
        String channelName = createCommand.getChannel();
        Integer owner = createCommand.getSenderId();
        boolean privacy = createCommand.isInviteOnly();

        if (!isValidName(channelName)) {
            return Broadcast.error(createCommand, ServerResponse.INVALID_NAME);
        }


        Channel toCreate = new Channel(channelName, owner, privacy);
        if (channels.contains(toCreate)) {
            return Broadcast.error(createCommand, ServerResponse.CHANNEL_ALREADY_EXISTS);
        }

        channels.add(toCreate);

        Collection<String> channelUsers = new LinkedList<>();
        channelUsers.add(getNickname(owner));

        return Broadcast.okay(createCommand, channelUsers);
    }

    /**
     * helper method that returns a channel with the given name, null otherwise
     * @param name the name of the channel we are trying to find
     * @return channel with the given name
     */
    private Channel findChannel(String name) {
        for (Channel c : channels) {
            if (c.getChannelName().equals(name)) {
                return c;
            }
        }
        return null;
    }

    /**
     * This method is called when a user wants to join a channel.
     * You can ignore the privacy aspect of this method for task 4, but
     * make sure you come back and implement it in task 5.
     * 
     * @param joinCommand The {@link JoinCommand} object containing all
     *                    information needed for the user's join attempt
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#names(Command, Collection, String)} if the user
     *         joins the channel successfully. The recipients should be all
     *         people in the joined channel (including the sender).
     *
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#NO_SUCH_CHANNEL} if there is no
     *         channel with the specified name
     *         (2) (after Task 5) {@link ServerResponse#JOIN_PRIVATE_CHANNEL} if
     *         the sender is attempting to join a private channel
     */
    public Broadcast joinChannel(JoinCommand joinCommand) {
        Integer joiner = joinCommand.getSenderId();
        Channel toJoin = findChannel(joinCommand.getChannel());
        if (toJoin == null) {
            return Broadcast.error(joinCommand, ServerResponse.NO_SUCH_CHANNEL);
        }

        if (toJoin.isPrivate()) {
            return Broadcast.error(joinCommand, ServerResponse.JOIN_PRIVATE_CHANNEL);
        }

        toJoin.addUser(joiner);
        Set<String> channelUsers = new TreeSet<>();
        for (Integer user: toJoin.getUsers()) {
            channelUsers.add(getNickname(user));
        }

        return Broadcast.names(joinCommand, channelUsers, getNickname(toJoin.getOwner()));
    }

    /**
     * This method is called when a user wants to send a message to a channel.
     * 
     * @param messageCommand The {@link MessageCommand} object containing all
     *                       information needed for the messaging attempt
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#okay(Command, Collection)} if the message
     *         attempt is successful. The recipients should be all clients
     *         in the channel.
     *
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#NO_SUCH_CHANNEL} if there is no
     *         channel with the specified name
     *         (2) {@link ServerResponse#USER_NOT_IN_CHANNEL} if the sender is
     *         not in the channel they are trying to send the message to
     */
    public Broadcast sendMessage(MessageCommand messageCommand) {
        Channel sentTo = findChannel(messageCommand.getChannel());
        if (sentTo == null) {
            return Broadcast.error(messageCommand, ServerResponse.NO_SUCH_CHANNEL);
        }

        if (! sentTo.getUsers().contains(messageCommand.getSenderId())) {
            return Broadcast.error(messageCommand, ServerResponse.USER_NOT_IN_CHANNEL);
        }

        Set<String> recipients = new TreeSet<>();
        for (Integer user: sentTo.getUsers()) {
            recipients.add(getNickname(user));
        }

        return Broadcast.okay(messageCommand, recipients);
    }

    /**
     * This method is called when a user wants to leave a channel.
     * 
     * @param leaveCommand The {@link LeaveCommand} object containing all
     *                     information about the user's leave attempt
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#okay(Command, Collection)} if the user leaves
     *         the channel successfully. The recipients should be all clients
     *         who were in the channel, including the user who left.
     * 
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#NO_SUCH_CHANNEL} if there is no
     *         channel with the specified name
     *         (2) {@link ServerResponse#USER_NOT_IN_CHANNEL} if the sender is
     *         not in the channel they are trying to leave
     */
    public Broadcast leaveChannel(LeaveCommand leaveCommand) {
        Integer leaver = leaveCommand.getSenderId();
        Channel toLeave = findChannel(leaveCommand.getChannel());

        if (toLeave == null) {
            return Broadcast.error(leaveCommand, ServerResponse.NO_SUCH_CHANNEL);
        }

        if (!toLeave.getUsers().contains(leaver)) {
            return Broadcast.error(leaveCommand, ServerResponse.USER_NOT_IN_CHANNEL);
        }

        Set<String> channelUsers = new TreeSet<>();
        for (Integer user: toLeave.getUsers()) {
            channelUsers.add(getNickname(user));
        }

        if (toLeave.getOwner().equals(leaver)) {
            channels.remove(toLeave);
        }

        toLeave.removeUser(leaver);

        return Broadcast.okay(leaveCommand, channelUsers);

    }

    // =============================
    // == Task 5: Channel Privacy ==
    // =============================

    // Go back to createChannel and joinChannel and add
    // all privacy-related functionalities, then delete this when you're done.

    /**
     * This method is called when a channel's owner adds a user to that channel.
     * 
     * @param inviteCommand The {@link InviteCommand} object containing all
     *                      information needed for the invite attempt
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#names(Command, Collection, String)} if the user
     *         joins the channel successfully as a result of the invite.
     *         The recipients should be all people in the joined channel
     *         (including the new user).
     *
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#NO_SUCH_USER} if the invited user
     *         does not exist
     *         (2) {@link ServerResponse#NO_SUCH_CHANNEL} if there is no channel
     *         with the specified name
     *         (3) {@link ServerResponse#INVITE_TO_PUBLIC_CHANNEL} if the
     *         invite refers to a public channel
     *         (4) {@link ServerResponse#USER_NOT_OWNER} if the sender is not
     *         the owner of the channel
     */
    public Broadcast inviteUser(InviteCommand inviteCommand) {
        Integer inviter = inviteCommand.getSenderId();
        Integer invitee = getUserId(inviteCommand.getUserToInvite());
        Channel c = findChannel(inviteCommand.getChannel());

        if (c == null) {
            return Broadcast.error(inviteCommand, ServerResponse.NO_SUCH_CHANNEL);
        }

        if (invitee.equals(-1)) {
            return Broadcast.error(inviteCommand, ServerResponse.NO_SUCH_USER);
        }

        if (!c.isPrivate()) {
            return Broadcast.error(inviteCommand, ServerResponse.INVITE_TO_PUBLIC_CHANNEL);
        }

        if (!c.getOwner().equals(inviter)) {
            return Broadcast.error(inviteCommand, ServerResponse.USER_NOT_OWNER);
        }

        c.addUser(invitee);
        Collection<String> recipients = getUsersInChannel(c.getChannelName());
        return Broadcast.names(inviteCommand, recipients, inviteCommand.getSender());

    }

    /**
     * This method is called when a channel's owner removes a user from
     * that channel.
     * 
     * @param kickCommand The {@link KickCommand} object containing all
     *                    information needed for the kick attempt
     * @return The {@link Broadcast} object generated by
     *         {@link Broadcast#okay(Command, Collection)} if the user is
     *         successfully kicked from the channel. The recipients should be
     *         all clients who were in the channel, including the user
     *         who was kicked.
     *
     *         If an error occurs, use
     *         {@link Broadcast#error(Command, ServerResponse)} with either:
     *         (1) {@link ServerResponse#NO_SUCH_USER} if the user being kicked
     *         does not exist
     *         (2) {@link ServerResponse#NO_SUCH_CHANNEL} if there is no channel
     *         with the specified name
     *         (3) {@link ServerResponse#USER_NOT_IN_CHANNEL} if the
     *         user being kicked is not a member of the channel
     *         (4) {@link ServerResponse#USER_NOT_OWNER} if the sender is not
     *         the owner of the channel
     */
    public Broadcast kickUser(KickCommand kickCommand) {
        Integer kicker = kickCommand.getSenderId();
        Integer kickee = getUserId(kickCommand.getUserToKick());
        Channel c = findChannel(kickCommand.getChannel());

        if (c == null) {
            return Broadcast.error(kickCommand, ServerResponse.NO_SUCH_CHANNEL);
        }

        if (kickee.equals(-1)) {
            return Broadcast.error(kickCommand, ServerResponse.NO_SUCH_USER);
        }

        if (!c.getOwner().equals(kicker)) {
            return Broadcast.error(kickCommand, ServerResponse.USER_NOT_OWNER);
        }
        if (!c.getUsers().contains(kickee)) {
            return Broadcast.error(kickCommand, ServerResponse.USER_NOT_IN_CHANNEL);
        }

        Collection<String> recipients = getUsersInChannel(c.getChannelName());
        c.removeUser(kickee);

        if (c.getOwner().equals(kickee)) {
            channels.remove(c);
        }

        return Broadcast.okay(kickCommand, recipients);

    }

}
