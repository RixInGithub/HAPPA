--[[
	a few notes...
	
	this interpreter isnt the best interpreter for a 2d esolang like HAPPA. expect bugs!
	also if truttle1 is reading this a java implementation would work way better than this monstrosity i created
]]

function makeErr(err)return(debug.getinfo(1,"S").source:sub(2)..":\x20error:\x20"..err)end
function printErr(err)return({print(makeErr(err)),"ERR!"})[2]end
function printUsage(extra)return({print("usage:\x20lua\x20"..debug.getinfo(1,"S").source:sub(2).."\x20file.hpa\n"..makeErr(extra)),"ERR!"})[2]end
function printCErr(err)return({print(err),"ERR!"})[2]end
function boolToNum(b)return((b)and(1))or(0)end -- it is psychopathic that i HAVE to do this to "attempt to perform arithmetic on a boolean value" stfu

function buildTbl(a)
	local b={}
	for c in(a)do(table.insert)(b,c)end
	return(b)
end

function normaliseCoed(a) -- equalizes each line length then splits string by lines then by character of each line. returns a 2d array.
	local c = -(math.huge)
	for d,e in ipairs(a)do
		if(#e)>(c)then(function()c=#(e)end)()end
	end
	local f = {}
	for d,e in ipairs(a)do
		f[d]=buildTbl((e..string.rep("\x20",c)):sub(1,c):gmatch(".")) -- pad e with space until e reaches length c then split by char
	end
	return(f)
end

function findBuggy(a) -- finds the top-right most h (caseinsensitive) in a 2d table
	found = false
	res = {}
	for a,b in ipairs(a) do
		res[1]=a
		for c,d in ipairs(b) do
			res[2]=c
			found=(found)or(d:lower()=="h") -- check if c is h (caseinsensitive)
			if(found)then;break;end
		end
		if(found)then;break;end
	end
	return((found)or(nil))and(res)
end

function main()
	if(nil)==arg[1]then;return(printUsage)("input\x20file\x20not\x20given")end
	local inpIO=(io.open)(arg[1],"r")
	if(not(inpIO))then;return(printUsage)("input\x20file\x20nonexistent")end
	local hPos,inp,hPos=table.unpack({nil,normaliseCoed(buildTbl(inpIO:lines())),nil})
	inpIO:close()
	inpIO=nil
	--[[
		for a,b in ipairs(inp)do
			print(table.concat(b,"").."|")
		end
	]]
	hPos=findBuggy(inp)
	while(nil==hPos)do;end -- "If the code has no bumper, the interpreter should just perform a `while (true) {/* do nothing */}` loop."
	local buggyV,crahsed,bumpedOn,stack,mirrors=table.unpack({{((inp[hPos[1]][hPos[2]]=="H")and(1))or(-1),1},0,nil,{},{}}) -- holy
	-- 0 indicates not-crashed, 1 indicates crashed into character and 2 indicates crashed into bounding box. also leave the misspellings alone pls
	while crahsed==0 do
		if((hPos[1]+buggyV[1])>#(inp[1]))or((hPos[1]+buggyV[1])<0)then
			crahsed=2
			break
		end
		hPos[1]=hPos[1]+buggyV[1]
		if((hPos[2]+buggyV[2])>#(inp))or((hPos[2]+buggyV[2])<0)then
			crahsed=2
			break
		end
		hPos[2]=hPos[2]+buggyV[2]
		print(hPos[1],hPos[2])
		bumpedOn=inp[hPos[1]][hPos[2]]
		if"\x20"~=(bumpedOn)then -- check if buggy bumped to a cmd, else just crash on a char
			if("|"==bumpedOn)or("-"==bumpedOn)then
				local mId=hPos[1]..","..hPos[2]
				mirrors[mId]=mirrors[mId]or(0)
				if(mirrors)[mId]==(20)then goto continue end -- if mirror was hit 20 times, skip it for funzies (standard btw)
				mirrors[mId]=mirrors[mId]+1
				local axis=boolToNum("-"==bumpedOn)+1
				buggyV[axis]=0-buggyV[axis]
				goto continue
			end
			if("?"==bumpedOn)or("/"==bumpedOn)then
				-- if(#out)~=(0)then(table.insert)(out,({print(),"\n"})[2])end
				-- table.insert(out,"? ")
				-- io.write("? ")
				local ch =string.byte(io.read(1))
				io.read(1) -- immediately read newline (im going insane rn)
				if(ch>=32)and(ch<=126)then
					table.insert(stack,internalASCII[ch+1])
					buggyV[1]=((bumpedOn=="?")and(1))or(-1)
					goto continue
				end
				-- print("debug: inputted",ch)
				buggyV[1]=((bumpedOn=="/")and(1))or(-1)
				goto continue
			end
			crahsed=1
			break
		end
		::continue::
	end
	if(crahsed==1)then;return(printCErr)("Move that "..inp[hPos[1]][hPos[2]].." out of the way!")end
	if(crahsed==2)then;return(printCErr)("Wheeeeh!")end
end

internalASCII={"\x00","\x01","\x02","\x03","\x04","\x05","\x06","\x07","\x08","\t","\n","\x0b","\x0c","\r","\x0e","\x0f","\x10","\x11","\x12","\x13","\x14","\x15","\x16","\x17","\x18","\x19","\x1a","\x1b","\x1c","\x1d","\x1e","\x1f"," ","!","\"","#","$","%","&","'","(",")","*","+","comma","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","\x7f"}
ascii={"␀","␁","␂","␃","␄","␅","␆","␇","␈","\t","\n","␋","␌","\r","␎","␏","␐","␑","␒","␓","␔","␕","␖","␗","␘","␙","␚","␛","␜","␝","␞","␟"," ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~","␡"}
-- internalASCII is the ascii table for stack and ascii is the ascii table for printing out those values.
a=pcall(debug.getlocal,4,1)or(os.exit)(main()=="ERR!") -- lua ignores lonely expressions, so i assign a var to the useless value.