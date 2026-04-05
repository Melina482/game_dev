extends Node
class_name AuthClass

var AccountInfo = [
	{ "username": "User1", "password": "userpass1" },
	{ "username": "User2", "password": "userpass2" }
]

func login_player(username: String, password: String) -> bool:
	for account in AccountInfo:
		if account["username"] == username and account["password"] == password:
			return true
	return false
