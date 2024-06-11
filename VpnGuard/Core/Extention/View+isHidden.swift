//
//  View+isHidden.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, removeIfHidden: Bool = false) -> some View {
        if hidden {
            if !removeIfHidden { self.hidden() }
        } else { self }
    }
}
