#!/usr/bin/gawk -f
# GeneQpdfCmd_PM1.awk
# gawk -f GeneQpdfCmd_PM1.awk SC_PM1.tsv
BEGIN{
	FS = "\t";
	Init();
}

($NF == "" && $1 != "年度"){
	split($2, URLs, "/");
	PDFName = URLs[length(URLs)];
	delete URLs;
	GetContents($2, PDFName);
	SLEEP();
	# https://texwiki.texjp.org/?QPDF#usage
	# Q1
	GeneratePDFName = $1"_午後1_問1.pdf";
	ExecQpdf($3, $4, GeneratePDFName);
	# Q2
	GeneratePDFName = $1"_午後1_問2.pdf";
	ExecQpdf($5, $6, GeneratePDFName);
	# Q3
	GeneratePDFName = $1"_午後1_問3.pdf";
	ExecQpdf($7, $8, GeneratePDFName);
	# Q4
	GeneratePDFName = $1"_午後1_問4.pdf";
	ExecQpdf($9, $10, GeneratePDFName);
	cmd_rm = "rm -f \042"PDFName"\042 > /dev/null 2>&1";
	system(cmd_rm);
	close(cmd_rm);
}

function ExecQpdf(Args_StartNo, Args_EndNo, Args_GeneratePDFName){
	Args_StartNo = Args_StartNo + 0;
	Args_EndNo = Args_EndNo + 0;
	if(Args_StartNo < 1 || Args_EndNo < 1){
		return;
	}
	cmd_Qpdf = "qpdf --decrypt \042"PDFName"\042 --pages \042"PDFName"\042 \042"Args_StartNo"-"Args_EndNo"\042 -- \042"Args_GeneratePDFName"\042";
	RetCode = system(cmd_Qpdf);
	close(cmd_Qpdf);
	if(RetCode != 0){
		print "qpdf has terminated abnormally. RetCode : "RetCode > "/dev/stderr";
		exit 99;
	}
}

function Init(){
	cmd_CheckQpdf = "which qpdf > /dev/null 2>&1";
	RetCode = system(cmd_CheckQpdf);
	close(cmd_CheckQpdf);
	if(RetCode != 0){
		print "Required qpdf. Install qpdf." > "/dev/stderr";
		exit 99;
	}
	cmd_CheckCurl = "which curl > /dev/null 2>&1";
	HTTP_Command = "CURL";
	RetCode = system(cmd_CheckCurl);
	close(cmd_CheckCurl);
	if(RetCode == 0){
		return;
	}
	cmd_CheckWget = "which wget > /dev/null 2>&1";
	RetCode = system(cmd_CheckWget);
	close(cmd_CheckWget);
	if(RetCode == 0){
		HTTP_Command = "WGET";
		return;
	}
	print "Required curl or wget. Install curl or wget." > "/dev/stderr";
	exit 99;
}

function EditHTTPResponse(){
	# HTMLに対しスパイダを掛け、HTTPレスポンスヘッダを取得する。
	# HTTPレスポンスヘッダは標準エラー出力として出るため、標準出力に統合している。
	if(HTTP_Command == "CURL"){
		cmd = "curl -D - -s  -o /dev/null \""MEXT_URL"\"";
	} else {
		cmd = "wget -q --spider -S \""MEXT_URL"\" 2>&1";
	}
	cnt = 1;
	while(cmd | getline esc){
		HTTPResArrays[cnt] = esc;
		cnt++;
	}
	close(cmd);
	if(HTTP_Command == "WGET"){
		for(i in HTTPResArrays){
			# 先頭の半角スペースを除去
			HTTPResArrays[i] = substr(HTTPResArrays[i],3);
		}
	}
	
	# HTTPリターンコードを取得
	status = 0;
	for(i in HTTPResArrays){
		print HTTPResArrays[i];
		mat = match(HTTPResArrays[i],/^HTTP\//);
		if(mat > 0){
			split(HTTPResArrays[i],SplitLine_HTTP);
			status = SplitLine_HTTP[2];
			delete SplitLine_HTTP;
			break;
		}
	}
	if (status >= 200) {
		return 0;
	} else {
		return 99;
	}
}

# ------------------------------------------------------------------------------------------------------------------------

function GetContents(GetContents_URL,GetContents_OUTFILE){
	if(HTTP_Command == "CURL"){
		cmd = "curl -s -o \""GetContents_OUTFILE"\" \""GetContents_URL"\"";
	} else {
		cmd = "wget -q \""GetContents_URL"\" -O \""GetContents_OUTFILE"\"";
	}
	ExecCmd(cmd);
}

# ------------------------------------------------------------------------------------------------------------------------

function SLEEP(){
	cmd = "sleep 5";
	ExecCmd(cmd);
}

# ------------------------------------------------------------------------------------------------------------------------

function EditHTTPResponse_02(EditHTTPResponse_02_URL){
	# HTMLに対しスパイダを掛け、HTTPレスポンスヘッダを取得する。
	# HTTPレスポンスヘッダは標準エラー出力として出るため、標準出力に統合している。
	if(HTTP_Command == "CURL"){
		cmd = "curl -D - -s  -o /dev/null \""EditHTTPResponse_02_URL"\"";
	} else {
		cmd = "wget -q --spider -S \""EditHTTPResponse_02_URL"\" 2>&1";
	}
	cnt = 1;
	while(cmd | getline esc){
		HTTPResArrays[cnt] = esc;
		cnt++;
	}
	close(cmd);
	if(HTTP_Command == "WGET"){
		for(i in HTTPResArrays){
			# 先頭の半角スペースを除去
			HTTPResArrays[i] = substr(HTTPResArrays[i],3);
		}
	}
	
	# HTTPリターンコードを取得
	status = 0;
	for(i in HTTPResArrays){
		mat = match(HTTPResArrays[i],/^HTTP\//);
		if(mat > 0){
			split(HTTPResArrays[i],SplitLine_HTTP);
			status = SplitLine_HTTP[2];
			delete SplitLine_HTTP;
			break;
		}
	}
	delete HTTPResArrays;
	if (status >= 200 && status < 300) {
		return 0;
	} else {
		return 99;
	}
}

function ExecCmd(CMDTEXT){
	system(CMDTEXT);
	close(CMDTEXT);
}

