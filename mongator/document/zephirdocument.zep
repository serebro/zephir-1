
/**
 * X
 */

namespace Mongator\Document;

class ZephirDocument
{
    public data;
    protected mongator;
    protected archive;
    protected fieldsModified;

    /**
     * Constructor.
     *
     * @param Mongator $mongator The Mongator.
     */
    public function __construct(<Mongator\Mongator> mongator)
    {
        this->setMongator(mongator);

        let this->archive = new Mongator\Archive();
        let this->data = [];
        let this->fieldsModified = [];
    }

    /**
     * Return the Archive object
     *
     * @return \Mongator\Archive the archive object from this document
     *
     * @api
     */
    public function getArchive()
    {
        return this->archive;
    }

    /**
     * Set the Mongator.
     *
     * @return Mongator The Mongator.
     */
    public function setMongator(<Mongator\Mongator> mongator)
    {
        let this->mongator = mongator;

        return this->mongator;
    }

    /**
     * Returns the Mongator.
     *
     * @return Mongator The Mongator.
     */
    public function getMongator()
    {
        return this->mongator;
    }

    /**
     * Returns the document metadata.
     *
     * @return array The document metadata.
     */
    public function getMetadata()
    {
        return this->getMongator()->getMetadataFactory()->getClass(get_class(this));
    }

    /**
     * Returns the document data.
     *
     * @return array The document data.
     */
    public function getDocumentData()
    {   
        return this->data;
    }


    /**
     * Returns an array with the fields modified, the field name as key and the original value as value.
     *
     * @return array An array with the fields modified.
     *
     * @api
     */
    public function getFieldsModified()
    {
        return this->fieldsModified;
    }

    /**
     * Clear the document modifications, that is, they will not be modifications apart from here.
     *
     * @api
     */
    public function clearModified()
    {
        var name, embedded, group;

        if isset this->data["fields"] {
            this->clearFieldsModified();
        }

        if isset this->data["embeddedsOne"] {
            this->clearEmbeddedsOneChanged();
            for name, embedded in this->data["embeddedsOne"] {
                if (embedded) {
                    embedded->clearModified();
                }
            }
        }

        if isset this->data["embeddedsMany"] {
            for name, group in this->data["embeddedsMany"] {
                group->markAllSaved();
            }
        }
    }

    /**
     * Clear the modifications of fields, that is, they will not be modifications apart from here.
     *
     * @api
     */
    public function clearFieldsModified()
    {
        let this->fieldsModified = [];
    }

    /**
     * Returns if the document is modified.
     *
     * @return bool If the document is modified.
     *
     * @api
     */
    public function isModified()
    {
        var name, value, embedded, rap;
        if isset this->data["fields"] {
            for name, value in this->data["fields"] {
                if this->isFieldModified(name) {
                    return true;
                }
            }
        }

        var root;
        if isset this->data["embeddedsOne"] {
            for name, embedded in this->data["embeddedsOne"] {
                if typeof embedded == "object" {
                    if embedded->isModified() {
                        return true;
                   }
                }

                if this->isEmbeddedOneChanged(name) {
                    let root = null;

                    //TODO: This is a workarround
                    if this->isInstanceOf("\\Mongator\\Document\\Document") {
                        let root = this;
                    } else {
                        let rap = this->getRootAndPath();
                        if rap {
                            let root = rap["root"];
                        }
                    }

                    if typeof root == "object" {
                        if !root->isNew() {
                            return true;
                        }
                    }
                }
            }
        }

        var group, add, document;
        if isset this->data["embeddedsMany"] {
            for name, group in this->data["embeddedsMany"] {
                let add = group->getAdd();
                for document in add {
                    if document->isModified() {
                        return true;
                    }
                }

                let root = null;
                //TODO: This is a workarround
                if this->isInstanceOf("\\Mongator\\Document\\Document") {
                    let root = this;
                } else {
                    let rap = this->getRootAndPath();
                    if rap {
                        let root = rap["root"];
                    }
                }

                if root {
                    if !root->isNew() {
                        if group->getRemove() {
                            return true;
                        }
                    }
                }

                if group->isSavedInitialized() {
                    if add {
                        return true;
                    }

                    for document in group->getSaved() {
                        if document->isModified() {
                            return true;
                        }
                    }
                }
            }
        }

        return false;
    }

    /**
     * Returns if a field is modified.
     *
     * @param string $name The field name.
     *
     * @return bool If the field is modified.
     *
     * @api
     */
    public function isFieldModified(var name)
    {
        return isset this->fieldsModified[name];
    }

    /**
     * Returns if an embedded one is changed.
     *
     * @param string $name The embedded one name.
     *
     * @return bool If the embedded one is modified.
     *
     * @api
     */
    public function isEmbeddedOneChanged(var name)
    {
        if !isset this->data["embeddedsOne"] {
            return false;
        }

        if !isset this->data["embeddedsOne"][name] {
            return false;
        }

        return this->getArchive()->has("embedded_one." . name);
    }


    /**
     * Returns the original value of a field.
     *
     * @param string $name The field name.
     *
     * @return mixed The original value of the field.
     *
     * @api
     */
    public function getOriginalFieldValue(var name)
    {
        if this->isFieldModified(name) {
            return this->fieldsModified[name];
        }

        if isset this->data["fields"] {
            if isset this->data["fields"][name] {
                return this->data["fields"][name];
            }
        }

        return null;
    }

    /**
     * Returns the original value of an embedded one.
     *
     * @param string $name The embedded one name.
     *
     * @return mixed The embedded one original value.
     *
     * @api
     */
    public function getOriginalEmbeddedOneValue(var name)
    {
        if this->getArchive()->has("embedded_one." . name) {
            return this->getArchive()->get("embedded_one." . name);
        }

        if isset this->data["embeddedsOne"] {
            if isset this->data["embeddedsOne"][name] {
                return this->data["embeddedsOne"][name];
            } 
        }

        return null;
    }

    /**
     * Returns an array with the embedded ones changed, with the embedded name as key and the original embedded value as value.
     *
     * @return array An array with the embedded ones changed.
     *
     * @api
     */
    public function getEmbeddedsOneChanged()
    {
        var name, embedded, embeddedsOneChanged;
        let embeddedsOneChanged = [];

        if isset this->data["embeddedsOne"] {
            for name, embedded in this->data["embeddedsOne"] {
                if this->isEmbeddedOneChanged(name) {
                    let embeddedsOneChanged[name] = this->getOriginalEmbeddedOneValue(name);
                }
            }
        }

        return embeddedsOneChanged;
    }

    /**
     * Clear the embedded ones changed, that is, they will not be changed apart from here.
     *
     * @api
     */
    public function clearEmbeddedsOneChanged()
    {
        var name, embedded;
        if isset this->data["embeddedsOne"] {
            for name, embedded in this->data["embeddedsOne"] {
                this->getArchive()->remove("embedded_one." . name);
            }
        }
    }


    /**
     * Returns the root and path of the embedded document.
     *
     * @return array An array with the root and path (root and path keys) or null if they do not exist.
     *
     * @api
     */
    public function getRootAndPath()
    {
        return null;
    }

    public function isInstanceOf(var $class)
    {

    }

}


