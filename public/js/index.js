function check(){//入力チェック欄
    let str = document.word.searchWord.value//検索語句を取得
    console.log(str)
    
    if(!str.match(/\S/g)){
        alert("空欄以外が含まれています");
    }

    for(var i=0 ; i<str.length; i++){
        var code=str.charCodeAt(i);
        if ((65<=code && code<=90) || (97<=code && code<=122)) {
            /* 半角英字（a-z,A-Z）の文字コード範囲 */
            /* 半角スペースも許容 */
        }else{
            alert("英字以外が含まれています");
            return false;
        }
        
        return true;
    }
}