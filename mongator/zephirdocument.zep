
/**
 * X
 */

namespace Mongator;

class ZephirDocument
{

    public function callFunction(var text)
    {
        if strlen(text) != 0 {
            return base64_encode(text);
        }

        return false;
    }

    public function callObjectMethod(var text)
    {
        var myObject;
        let myObject = new ExampleClass();

        return myObject->method(text);
    }

}


