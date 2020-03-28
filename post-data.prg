// Copyright (c) 2020 the post-data contributors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


// -----------------------------------------------------------------------------


// The entry point to this library. Parses the current request's body according
// to the format given in the request's headers, and returns a hash representing
// the POST data, or `nil` if the format of the body isn't recognized.
// Currently, both the keys and values in the returned hash are strings.
function PostData()
    local ret, bodyContentType, paramBoundary, mimeEssence

    bodyContentType := hb_HGetDef(AP_HeadersIn(), "Content-Type", "")

    // Find the first space, comma or semicolon in `bodyContentType`.
    paramBoundary := At(bodyContentType, ';')
    if paramBoundary == 0 .OR. At(bodyContentType, ',') < paramBoundary
        paramBoundary := At(bodyContentType, ',')
    endif
    if paramBoundary == 0 .OR. At(bodyContentType, ' ') < paramBoundary
        paramBoundary := At(bodyContentType, ' ')
    endif

    // Now, the part of `bodyContentType` left of the first space, comma or
    // semicolon makes up the essence of the MIME type. We also lowercase it for
    // good measure.
    if paramBoundary == 0
        mimeEssence := Lower(bodyContentType)
    else
        mimeEssence := Lower(Left(bodyContentType, paramBoundary - 1))
    endif

    // Use the appropriate decoder based on the body's MIME type.
    do case
        case mimeEssence == "application/x-www-form-urlencoded"
            ret := ParseUrlencoded(AP_Body())

        case mimeEssence == "application/json"
            ret := hb_jsonDecode(AP_Body())

        // TODO: multipart/form-data
        
        otherwise
            ret := nil
    endcase

return ret

// -----------------------------------------------------------------------------

// Parses the `application/x-www-form-urlencoded` format, returning a hash
// representing the POST data. Both the keys and values are strings.
function ParseUrlencoded(string)
    // This function is based on the `AP_PostPairs` function from mod_harbour.
    // Copyright (c) FiveTech Software SL, 2019-2020
    // Available under the MIT license.

    local cPair, uPair, name, value, hPairs := {=>}

    for each cPair in hb_ATokens(string, "&")
        if (uPair := At("=", cPair)) > 0
            name := Left(cPair, uPair - 1)
            value := SubStr(cPair, uPair + 1)
        else
            // By the parsing algorithm given in the WHATWG URL standard
            // (https://url.spec.whatwg.org/#application/x-www-form-urlencoded),
            // if a pair contains no '=' character, it should be interpreted as
            // a name that maps to the empty value.
            name := cPair
            value := ""
        endif

        // Both the name and value must be percent-decoded (with plus signs
        // replaced by spaces). The resulting strings are usually UTF-8-encoded.
        hb_HSet(hb_UrlDecode(name), hb_UrlDecode(value))
   next
return nil
