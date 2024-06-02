package org.cis1200;

import java.util.TreeSet;

/**
 * Class responsible for creation of channels, storing information about the channels current users,
 * owner, publicity status, and name
 * Users can be added and removed
 */
public class Channel {
    private final boolean isPrivate;
    private TreeSet<Integer> users;
    private final Integer owner;
    private final String channelName;

    public Channel(String name, Integer owner, boolean isPrivate) {
        this.isPrivate = isPrivate;
        this.channelName = name;
        this.owner = owner;
        users = new TreeSet<>();
        users.add(owner);
    }

    /**
     * gets the channels privacy status; if the channel is public, returns true.
     * if the channel is private, returns false
     * @return privacy
     */
    public boolean isPrivate() {
        return isPrivate;
    }

    /**
     * returns a copy of the set of user IDs currently in the channel.
     * @return
     */
    public TreeSet<Integer> getUsers() {
        TreeSet<Integer> usersCopy = new TreeSet<>();
        usersCopy.addAll(users);
        return usersCopy;
    }

    /**
     * adds a user ID to the channel.
     * if the user is unsuccessfully added to the channel (because they
     * are already in it or otherwise) returns false.
     * returns true if user is successfully added
     * @param user
     * @return
     */
    public boolean addUser(Integer user) {
        return users.add(user);
    }

    /**
     * removes a user ID from the channel. if the user is unsuccessfully removed (because they
     * aren't in the channel or otherwise) returns false.
     * returns true if user is successfully removed
     * clears the entire channel if the owner is removed
     * @return
     */
    public boolean removeUser(Integer user) {
        if (user == owner) {
            users.clear();
            return true;
        }
        return users.remove(user);
    }

    /**
     * returns the owner of the channel
     * @return
     */
    public Integer getOwner() {
        return owner;
    }

    /**
     * returns the channel name
     * @return
     */
    public String getChannelName() {
        return channelName;
    }

    @Override
    public boolean equals(Object other) {
        if (other.getClass() == this.getClass()) {
            Channel c = (Channel) other;
            if (c.getChannelName().equals(this.getChannelName())) {
                return true;
            }
        }
        return false;
    }
}
