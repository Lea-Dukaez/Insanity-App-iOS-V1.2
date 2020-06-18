//
//  File.swift
//  Insanity
//
//  Created by Léa on 24/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

struct K {
    static let appName = "INSANITY"
    static let segueToProgress = "goToProgress"
    static let segueLoginToHome = "loginToHome"
//    static let segueSignUpToAccount = "signUpToAccount"
    static let segueSignUpToHome = "signUpToHome"
//    static let segueAccountToProfile = "accountToProfile"
    static let segueResultsToTest = "goToTest"
    static let segueHomeToAccount = "goToAccount"
    static let segueWelcomeToHome = "welcomeToHomeloggedIn"
    static let segueToReset = "goToReset"
    static let segueGoToAddFriends = "goToAddFriends"
    
    static let avatarImages = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8", "avatar9", "avatar10", "avatar11", "avatar12", "avatar13", "avatar14", "avatar15", "avatar16", "avatar17", "avatar18"]
    static let reuseAvatarIdentifier = "reuseAvatarCell"
    
    
    struct BrandColor {
        static let blueGreyBrandColor = "BlueGreyBrandColor"
        static let greenBrandColor = "GreenBrandColor"
    }
    
    struct userCell {
        static let userCellIdentifier = "myReusableCell"
        static let userCellNibName = "UserCell"
        static let addFriendCellIdentifier = "reuseAddFriend"
        static let addFriendCellNibName = "AddFriendCell"
        static let noOpponentAvatar = "noOpponentAvatar"
        static let usersAvatar = ["MalekAvatar", "LeaAvatar", "MathAvatar", "LouxAvatar"]
        static let usersLabel = ["Malfouf, le Nul", "Lea, fit Courgette", "Mathou, super Blonde", "Loux, nihon Kyojin"]
    }
    
    
    
    struct workout {
        static let workoutMove = ["Switch Kicks", "Power Jack", "Power Knees", "Power Jump", "Global Jump", "Suicide Jump", "Push-Up Jack", "Low Plank Oblique" ]
        static let workoutCellIdentifier = "workoutMoveCell"
        static let workoutCellNibName = "WorkoutCell"
    }
    
    struct podium {
        static let first = "Well done ! You surpass them all. As Ayrton Senna said : 'I am not designed to come second or third. I am designed to win.'"
        static let second = "Very good score but not good enough to reach for the first place !"
        static let third = "At least you reach the podium ! Good job"
        static let notOnPodium = "Sorry you miss the podium. But the best reward is improving your results. isn't it?"
    }
    
    struct FStore {
        static let collectionTestName = "workoutTests"
        static let dateField = "date"
        static let idField = "id"
        static let testField = "testResults"
        static let collectionUsersName = "users"
        static let nameField = "name"
        static let pseudoField = "pseudo"
        static let maxField  = "max"
        static let avatarField = "avatar"
        static let users = ["Malek", "Lea", "Math", "Loux"]
        
    }
    

        



}
