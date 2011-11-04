xquery version "1.0";
(:~ index for the user API
 :
 : Open Siddur Project
 : Copyright 2011 Efraim Feinstein <efraim@opensiddur.org>
 : Licensed under the GNU Lesser General Public License, version 3 or later
 :
 :)
module namespace index="http://jewishliturgy.org/api/user";

import module namespace api="http://jewishliturgy.org/modules/api" 
	at "/code/api/modules/api.xqm";

declare default element namespace "http://www.w3.org/1999/xhtml"; 

declare variable $index:allowed-methods := "GET";
declare variable $index:accept-content-type := api:html-content-type();
declare variable $index:request-content-type := ();
declare variable $index:test-source := "/code/tests/api/user/user.t.xml";

declare function index:title(
  $uri as xs:anyAtomicType
  ) as xs:string {
  let $user-name := substring-after($uri, "/user/")
  return
    if ($user-name)
    then $user-name
    else "User API"
};

declare function index:allowed-methods(
  $uri as xs:anyAtomicType
  ) as xs:string* {
  $index:allowed-methods
};

declare function index:accept-content-type(
  $uri as xs:anyAtomicType
  ) as xs:string* {
  $index:accept-content-type
};

declare function index:request-content-type(
  $uri as xs:anyAtomicType
  ) as xs:string* {
  $index:request-content-type
};

declare function index:list-entry(
  $uri as xs:anyAtomicType
  ) as element(li) {
  api:list-item(
    element span {index:title($uri)},
    $uri,
    index:allowed-methods($uri),
    index:accept-content-type($uri),
    index:request-content-type($uri),
    ()
  )
};

declare function local:disallowed() {
  api:allowed-method($index:allowed-methods),
  api:error((), "Method not allowed")
};

declare function index:get() {
  let $test-result := api:tests($index:test-source)
  let $accepted := api:get-accept-format($index:accept-content-type)
  return
    if (not($accepted instance of element(api:content-type)))
    then $accepted
    else if ($test-result)
    then $test-result
    else (
      api:serialize-as("xhtml", $accepted),
      let $user-name := request:get-parameter('user-name', ())
      let $base := '/code/api/user'
      let $list-body := (
        <ul class="common">{
          api:list-item(
            <span>Session-based login</span>,
            concat($base, "/login"),
            ("GET","POST","PUT","DELETE"),
            api:html-content-type(),
            ( api:xml-content-type(), 
              api:form-content-type(),
              api:text-content-type()
            ),
            ()
          ),
          api:list-item(
            <span>Session-based logout</span>,
            concat($base, "/logout"),
            ("GET", "POST", "DELETE"),
            api:html-content-type(),
            ( api:xml-content-type(), 
              api:form-content-type(),
              api:text-content-type()
            ),
            ()
          )
        }</ul>,
        if ($user-name)
        then
          <ul class="results">{
            api:list-item(
              <span>{$user-name}</span>,
              concat($base, "/", $user-name),
              ("GET","PUT"),
              api:html-content-type(),
              ( api:xml-content-type(), 
                api:form-content-type(),
                api:text-content-type()
              ),
              ()
            )
          }</ul>
        else ()
      )
      return
        api:list(
          <title>Open Siddur User API</title>,
          $list-body,
          count($list-body/self::ul[@class="results"]/li),
          false(),
          $index:allowed-methods,
          $index:accept-content-type,
          $index:request-content-type,
          $index:test-source
        )
    )
};

declare function index:put() {
  local:disallowed()
};

declare function index:post() {
  local:disallowed()
};

declare function index:delete() {
  local:disallowed()
};

declare function index:go() {
  let $method := api:get-method()
  return
    if ($method = "GET")
    then index:get()
    else local:disallowed()
};

