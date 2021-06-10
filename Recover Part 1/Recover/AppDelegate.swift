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
import CareKitStore
import UIKit
import os.log

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let storeManager = OCKSynchronizedStoreManager(
        wrapping: OCKStore(
            name: "com.apple.wwdc.carekitstore",
            type: .inMemory
        )
    )
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
            launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        seedTasks()

        return true
    }

    // MARK: UISceneSession Life Cycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    // MARK: Seeding the Store

    private func seedTasks() {

        // 1.1 Persist an onboarding task
    }
}

