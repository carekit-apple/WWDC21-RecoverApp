/*
 Copyright © 2021 Apple Inc. All rights reserved.

 Apple permits redistribution and use in source and binary forms, with or without
 modification, providing that you adhere to the following conditions:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions, and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions, and the following disclaimer in the documentation and
 other distributed materials.

 3. You may not use the name of the copyright holders nor the names of any contributors
 to endorse or promote products that derive from this software without specific prior
 written permission. Apple does not grant license to the trademarks of the copyright
 holders even if this software includes such marks.

 THE COPYRIGHT HOLDERS AND CONTRIBUTORS PROVIDE THIS SOFTWARE "AS IS”, AND DISCLAIM ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 OR CONSEQUENTIAL  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) WHATEVER THE CAUSE AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF YOU
 ADVISE THEM OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var storeManager: OCKSynchronizedStoreManager {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.storeManager
    }

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let feed = CareFeedViewController(storeManager: appDelegate.storeManager)
        feed.title = "Care Feed"
        feed.tabBarItem = UITabBarItem(
            title: "Care Feed",
            image: UIImage(systemName: "heart.fill"),
            tag: 0
        )

        let insights = InsightsViewController(storeManager: appDelegate.storeManager)
        insights.title = "Insights"
        insights.tabBarItem = UITabBarItem(
            title: "Insights",
            image: UIImage(systemName: "waveform.path.ecg.rectangle.fill"),
            tag: 1
        )

        let root = UITabBarController()
        let feedTab = UINavigationController(rootViewController: feed)
        let insightsTab = UINavigationController(rootViewController: insights)
        root.setViewControllers([feedTab, insightsTab], animated: false)

        window = UIWindow(windowScene: scene as! UIWindowScene)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
    }
}
