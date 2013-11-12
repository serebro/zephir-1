
/**
 * X
 */

namespace Mongator;

class Archive
{
    private archive;
    private keys;

    public function __construct()
    {
        let this->archive = [];
        let this->keys = [];
    }

    /**
     * Returns if has a key in the archive.
     *
     * @param string $key    The key.
     *
     * @return bool If key in the archive.
     */
    public function has(var key)
    {
        //TODO: Unset not works
        if isset this->keys[key] {
            if this->keys[key] == null {
                return false;
            }
        } else {
            return false;
        }

        return true;
    }

    /**
     * Returns the value of a key.
     *
     * It does not check if the object key exists, if you want to check it, do by yourself.
     *
     * @param string $key    The key.
     *
     * @return mixed The value of the key.
     */
    public function get(var key)
    {
        return this->archive[key];
    }

    /**
     * Set a key value.
     *
     * @param string $key    The key.
     * @param mixed  $value  The value.
     */
    public function set(var key, value)
    {
        let this->keys[key] = true;
        let this->archive[key] = value;
    }

    /**
     * Remove a key.
     *
     * @param string $key    The key.
     */
    public function remove(var key)
    {
        if !this->has(key) {
            return;
        }

        let this->archive[key] = null;
        let this->keys[key] = null;

        unset this->archive[key];
        unset this->keys[key];
    }

    /**
     * Returns a key by reference. It creates the key if the key does not exist.
     *
     * @param string $key     The key.
     * @param mixed  $default The default value, used to create the key if it does not exist (null by default).
     *
     * @return mixed The object key value.
     */
    public function getByRef(var key, defaultValue=null)
    {
        if !this->has(key) {
            this->set(key, defaultValue);
        }

        return this->archive[key];
    }

    /**
     * Returns an object key or returns a default value otherwise.
     *
     * @param string $key     The key.
     * @param mixed  $default The value to return if the object key does not exist.
     *
     * @return mixed The object key value or the default value.
     */
    public function getOrDefault(var key, defaultValue)
    {
        if this->has(key) {
            return this->get(key);
        }

        return defaultValue;
    }

    /**
     * Returns all objects data.
     *
     * @return array All objects data.
     */
    public function all()
    {
        return this->archive;
    }

    /**
     * Clear all objects data.
     */
    public function clear()
    {
        let this->archive = [];
    }
}


