
// SceneDelegate.swift
// Friends_and_events
// Created by ginger on 15/5/2024.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Called when the scene is being created and attached to a session.
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    // Called as the scene is being released by the system.
    func sceneDidDisconnect(_ scene: UIScene) {
        // This is where you can release any resources that were associated with this scene.
    }

    // Called when the scene has moved from an inactive state to an active state.
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    // Called when the scene will move from an active state to an inactive state.
    func sceneWillResignActive(_ scene: UIScene) {
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    // Called as the scene transitions from the background to the foreground.
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo the changes made on entering the background.
    }

    // Called as the scene transitions from the foreground to the background.
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
