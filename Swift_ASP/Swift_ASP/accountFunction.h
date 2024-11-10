//
//  accountFunction.h
//  Swift_ASP
//
//  Created by ZH Chen on 2024/11/9.
//

#ifndef accountFunction_h
#define accountFunction_h

struct User {
    var username: String
    var password: String // In real applications, do not store passwords as plain text
}

var users: [User] = []

func register(username: String, password: String) -> Bool {
    if users.contains(where: { $0.username == username }) {
        return false // Username already taken
    }
    let newUser = User(username: username, password: password)
    users.append(newUser)
    return true // Successful registration
}

func login(username: String, password: String) -> Bool {
    guard let user = users.first(where: { $0.username == username }) else {
        return false // User not found
    }
    return user.password == password // Check password
}

var loggedInUser: User?

func setSession(user: User?) {
    loggedInUser = user
}



#endif /* accountFunction_h */
