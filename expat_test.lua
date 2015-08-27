local expat = require'expat'
local pp = require'pp'

local callbacks = setmetatable({}, {__index = function(t,k) return function(...) print(k,...) end end})
expat.parse({path='media/svg/zorro.svg'}, callbacks)
pp(expat.treeparse{path='media/svg/zorro.svg'})


--[[Test for CVE-2013-0340 vulnerability

According to http://www.openwall.com/lists/oss-security/2013/04/12/6 this is apparently not going
to be fixed directly by expat, but only on an application per application level. We rather adopt
a safe default inspired by apr_xml_parser, and abort parsing if entity declarations are present.
Users who need entity declarations to work should override the callback.

See http://svn.apache.org/viewvc/apr/apr/trunk/xml/apr_xml.c?r1=757729&r2=781403&pathrev=781403
]]--
assert(not pcall(function()
pp(expat.treeparse{string=[[<?xml version="1.0"?>
<!DOCTYPE billion [
<!ELEMENT billion (#PCDATA)>
<!ENTITY laugh0 "ha">
<!ENTITY laugh1 "&laugh0;&laugh0;">
<!ENTITY laugh2 "&laugh1;&laugh1;">
<!ENTITY laugh3 "&laugh2;&laugh2;">
<!ENTITY laugh4 "&laugh3;&laugh3;">
<!ENTITY laugh5 "&laugh4;&laugh4;">
<!ENTITY laugh6 "&laugh5;&laugh5;">
<!ENTITY laugh7 "&laugh6;&laugh6;">
<!ENTITY laugh8 "&laugh7;&laugh7;">
<!ENTITY laugh9 "&laugh8;&laugh8;">
<!ENTITY laugh10 "&laugh9;&laugh9;">
<!ENTITY laugh11 "&laugh10;&laugh10;">
<!ENTITY laugh12 "&laugh11;&laugh11;">
<!ENTITY laugh13 "&laugh12;&laugh12;">
<!ENTITY laugh14 "&laugh13;&laugh13;">
<!ENTITY laugh15 "&laugh14;&laugh14;">
<!ENTITY laugh16 "&laugh15;&laugh15;">
<!ENTITY laugh17 "&laugh16;&laugh16;">
<!ENTITY laugh18 "&laugh17;&laugh17;">
<!ENTITY laugh19 "&laugh18;&laugh18;">
<!ENTITY laugh20 "&laugh19;&laugh19;">
<!ENTITY laugh21 "&laugh20;&laugh20;">
<!ENTITY laugh22 "&laugh21;&laugh21;">
<!ENTITY laugh23 "&laugh22;&laugh22;">
<!ENTITY laugh24 "&laugh23;&laugh23;">
<!ENTITY laugh25 "&laugh24;&laugh24;">
<!ENTITY laugh26 "&laugh25;&laugh25;">
<!ENTITY laugh27 "&laugh26;&laugh26;">
<!ENTITY laugh28 "&laugh27;&laugh27;">
<!ENTITY laugh29 "&laugh28;&laugh28;">
<!ENTITY laugh30 "&laugh29;&laugh29;">
]>
<billion>&laugh30;</billion>]]})
end))


function soaptest(xmlsrc)
	local xmlsoap = expat.treeparse({
		namespacesep = '|',
		string = xmlsrc})
	print('tag = '..pp.format(xmlsoap
		.tags['http://schemas.xmlsoap.org/soap/envelope/|Envelope']
		.tags['http://schemas.xmlsoap.org/soap/envelope/|Body']
		.children[1]
		.tag))
	for k,v in pairs(xmlsoap
			.tags['http://schemas.xmlsoap.org/soap/envelope/|Envelope']
			.tags['http://schemas.xmlsoap.org/soap/envelope/|Body']
			.children[1]
			.tags) do
		print(k..' = '..pp.format(v.cdata))
	end
	print''
end

--[[Both testcases below should generate the same output:
tag = 'http://test.soap.service.luapower.com/|serviceA'
paramB = 'SOME STUFF'
paramC = '123'
paramA = nil
]]--

-- Envelope generated by Python Suds 0.4.1
soaptest[[<?xml version="1.0" encoding="UTF-8"?>
	<SOAP-ENV:Envelope xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
			xmlns:ns0="http://schemas.xmlsoap.org/soap/encoding/"
			xmlns:ns1="http://test.soap.service.luapower.com/"
			xmlns:ns2="http://schemas.xmlsoap.org/soap/envelope/"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
			SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
		<SOAP-ENV:Header/>
		<ns2:Body>
			<ns1:serviceA>
				<paramA></paramA>
				<paramB>SOME STUFF</paramB>
				<paramC>123</paramC>
			</ns1:serviceA>
		</ns2:Body>
	</SOAP-ENV:Envelope>]]

-- Envelope generated by Apache CXF 2.7.1
soaptest[[<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
		<soap:Body>
			<ns1:serviceA xmlns:ns1="http://test.soap.service.luapower.com/">
				<paramA></paramA>
				<paramB>SOME STUFF</paramB>
				<paramC>123</paramC>
			</ns1:serviceA>
		</soap:Body>
	</soap:Envelope>]]