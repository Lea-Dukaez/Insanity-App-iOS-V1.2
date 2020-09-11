//
//  File.swift
//  Insanity
//
//  Created by Léa on 24/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

struct K {
    
    static let appName = "INSANITY"

    
    struct Segue {
        struct WelcomeVC {
            static let segueWelcomeToSignUp = "welcomeToSignUP"
            static let segueWelcomeToLogIn = "welcomeToLogIn"
            static let segueWelcomeToHome = "welcomeToHomeloggedIn"
        }
        struct LoginVC {
            static let segueLoginToHome = "loginToHome"
            static let segueLogInToSignUp = "logInToSignUp"
            static let segueGoToForgotPassword = "goToForgotPassword"
        }
        struct SignUpVC {
            static let segueSignUpToHome = "signUpToHome"
            static let segueSignUpToLogIn = "signUpToLogIn"
            static let segueSignUpGoToTerms = "signUpGoToTerms"
        }
        struct ProfileVC {
            static let segueProfileToSettings = "ProfileToSettings"
            static let segueGoToAddFriends = "goToAddFriends"
            static let segueGoToFriendActivity = "goToFriendActivity"
            static let segueGoToFollowers = "goToFollowers"
        }
        static let segueToProgress = "goToProgress"
        static let segueSettingsToInfos = "settingsToInfos"
        static let segueResultsToTest = "goToTest"
        static let segueToReset = "goToReset"
        static let segueResetGoBackToLogIn = "resetGoBackToLogIn"
        static let segueInfoGoToTerms = "infoGoToTerms"
    }
    
    
    
    

    
    
    
    static let avatarImages = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8", "avatar9", "avatar10", "avatar11", "avatar12", "avatar13", "avatar14", "avatar15", "avatar16", "avatar17", "avatar18", "avatar19", "avatar20", "avatar21", "avatar22", "avatar23", "avatar24"]
    static let reuseAvatarIdentifier = "reuseAvatarCell"
    
    
    struct BrandColor {
        static let blueGreyBrandColor = "BlueGreyBrandColor"
        static let greenBrandColor = "GreenBrandColor"
        static let orangeBrancColor = "BrandOrangeColor"
    }
    
    struct userCell {
        static let userCellIdentifier = "myReusableCell"
        static let userCellNibName = "UserCell"
        static let addFriendCellIdentifier = "reuseAddFriend" 
        static let addFriendCellNibName = "AddFriendCell"
        static let noOpponentAvatar = "noOpponentAvatar"
    }
    
    
    struct workout {
        static let calendar = [0,1,2,3,4,5,2,15,
                        0,3,5,2,4,3,6,15,
                        0,1,2,6,4,3,2,15,
                        0,6,3,2,4,6,2,15,
                        0,7,7,7,7,7,7,15,
                        0,8,9,10,11,12,9,15,
                        0,10,12,9,11,13,7,15,
                        0,14,9,10,11,12,7,15,
                        0,9,13,12,7,9,13,1]
        static let programm = [0:"week", 1:"Fit Test", 2:"Plyo Cardio Circuit", 3:"Cardio Power & Resistance", 4:"Cardio Recovery", 5:"Pure Cardio", 6:"Pure Cardio & Abs", 7:"Core Cardio & Balance", 8:"Fit Test / Max Interval Training", 9:"Max Interval Plyo", 10:"Max Cardio Conditioning", 11:"Max Recovery", 12:"Max Interval Circuit", 13:"Max Cardio Conditioning & Abs", 14:"Fit Test/ Max Interval Circuit",15:"Rest"]
        static let workoutMove = ["Switch Kicks", "Power Jacks", "Power Knees", "Power Jumps", "Globe Jumps", "Suicide Jumps", "Push-Up Jacks", "Low Plank Oblique" ]
        static let workoutCellIdentifier = "workoutMoveCell"
        static let workoutCellNibName = "WorkoutCell"
    }
    
    struct podium {
        static let first = "Well done ! You surpass them all. As Ayrton Senna said : 'I am not designed to come second or third. I am designed to win.'"
        static let second = "Very good score but not good enough to reach for the first place !"
        static let third = "At least you reach the podium ! Good job"
        static let notOnPodium = "Sorry you miss the podium. But the best reward is improving your results. isn't it? Your best score for this exercice is: "
    }
    
    struct FStore {
        struct Users {
            static let collectionUsersName = "users"
            static let nameSearchField = "nameSearch"
            static let pseudoField = "pseudo"
            static let maxField  = "max"
            static let avatarField = "avatar"
            static let calendarField = "calendar"
            static let followedUsersField = "followedUsers"
            static let numberOfTestsField = "numberOfTests"

        }
        
        struct WorkoutTests {
            static let collectionTestName = "workoutTests"
            static let dateField = "date"
            static let idField = "id"
            static let testField = "testResults"
            static let canceledField = "canceled"
        }
        
        struct Relationships {
            static let collectionRelationshipsName = "relationships"
            static let statusField = "status"
            static let friendIDField = "friendID"
            static let userIDField = "userID"
            static let statusWaitingApproval = "waitingApproval"
            static let statusFollowing = "following"
        }
        
    }

}
