module uim.server.logging;

import uim.server;

string baseUrl;

string numberToISOExtString(string number) {
	auto ts = SysTime(to!size_t(number));
	return ts.toISOExtString.split(".")[0];
}

string readFromRequest(HTTPServerRequest req, string name, string defaultValue = "") {
	if (name in req.query) return req.query[name];
	if (name in req.params) return req.params[name];
	if (name in req.form) return req.form[name];
	if (req.session) if (req.session.isKeySet(name)) return req.session.get!string(name);	
	//	if (name in onsDefaults) return onsDefaults[name];
	
	return defaultValue;
}

string readFromRequest(HTTPServerRequest req, string name, string[string] values) {
	if (name in req.query) return req.query[name];
	if (name in req.params) return req.params[name];
	if (name in req.form) return req.form[name];
	if (req.session) if (req.session.isKeySet(name)) return req.session.get!string(name);	
	if (name in values) return values[name];
	//	if (name in onsDefaults) return onsDefaults[name];
	
	return "";
}
string[string] readFromRequest(HTTPServerRequest req, string[] names) {
	string[string] result;
	foreach(name; names) result[name] = readFromRequest(req, name);
	return result;
}

string[string] readFromRequest(HTTPServerRequest req, string[string] values = null) {
	string[string] result = values;
//	result["lang"] = readFromRequest(req, "lang", "en");
//	result["url"] = req.requestURL;
//	result["path"] = req.path;
//	result["contentType"] = req.contentType;
//	result["host"] = req.host;
//	result["password"] = req.password;
//	result["peer"] = req.peer;
//	result["queryString"] = req.queryString;
//	result["qString"] = "?"~result["queryString"];
//	result["userName"] = req.username;
//	result["rootDir"] = req.rootDir;
	
	foreach(k, v; req.query) if (k !in result) result[k] = v; else result[k] = result[k]~","~v; 
	foreach(k, v; req.form) if (k !in result) result[k] = v; else result[k] = result[k]~","~v;
	foreach(k, v; req.params) if (k !in result) result[k] = v; else result[k] = result[k]~","~v;
	// foreach(k, v; values) if (k !in result) result[k] = readFromRequest(req, k, values[k]); else result[k] = result[k]~","~readFromRequest(req, k);
	//	foreach(k, v; onsDefaults) if (k !in result) result[k] = readFromRequest(req, k);

	writeln(result);
	return result;
}

long dateToLong(string value) {
	return SysTime.fromISOExtString(value).stdTime;
}

void logRequest(string[string] values) {
	Bson result = Bson.emptyObject;
	foreach(k, v; values) result[k] = v;
	result["ts"] = nowForJs;
	result["date"] = now().toISOExtString;
	iServer.log(result);
}

string currentSessionId(STRINGAA parameters, HTTPServerRequest req) {
	auto sessionId = guestSessionId;
	if (auto session = req.session) {
		if (session.isKeySet("session")) {
			sessionId = session.get!string("session"); 
			parameters["login"] = sessionId;
		}}
	
	parameters["sessionId"] = sessionId;
	return sessionId;
}

bool validLogin(HTTPServerRequest req, UIMSession[string] sessions) {
	if (auto session = req.session) {
		if (session.isKeySet("session")) {
			auto token = session.get!string("session");
			if (token in sessions) {
				auto _session = sessions[token];	
				auto lastAccess = _session.lastAccess;
				auto currentAccess = req.timeCreated; 
				Duration duration = currentAccess - lastAccess;
				auto peer = _session.peer;
				sessions[token].lastAccess = currentAccess; // refresh current time
				return true;
			}}}
	return false;
}