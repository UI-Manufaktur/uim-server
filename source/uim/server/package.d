module uim.server;

public import std.stdio;
public import std.string;
public import std.file;
public import std.uuid;

public import vibe.d;

public import uim.oop;
public import uim.core;
public import uim.data;
public import uim.web;
public import uim.css;
public import uim.json;
public import uim.js;
public import uim.html;
public import uim.bootstrap;
public import uim.vue;
public import uim.bootstrap.vue;
public import uim.rest.api;

public import uim.server.logging;

string[string] accounts;

struct UIMSession {
	SysTime lastAccess;
	string peer;
	string account;
}
UIMSession[string] sessions;

string[string] sitesUUIDs;

string sessionId;
string guestSessionId;

string subString(string txt, size_t maxLength = 150) {
	string result = txt;
	if (result.length > maxLength) result = result[0..maxLength]~"...";
	return result;
}

string germanDate(long mSecs) {
	auto systime = SysTime.fromUnixTime(mSecs/1000);
	return "%s.%s.%s".format(systime.day, cast(int)systime.month, systime.year);
}

string germanDateTime(long mSecs) {
	auto systime = SysTime.fromUnixTime(mSecs/1000);
	return "%s.%s.%s %s:%s:%s".format(systime.day, cast(int)systime.month, systime.year, systime.hour, systime.minute, systime.second);
}
