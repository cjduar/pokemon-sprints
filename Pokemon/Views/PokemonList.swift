////
////  LandmarkList.swift
////  Landmarks
////
////  Created by Christopher Duarte on 7/17/23.
////
//
//import SwiftUI
//
//struct LandmarkList: View {
//    var body: some View {
//        NavigationView{
//            List(landmarks) { landmark in
//                NavigationLink {
//                    LandmarkDetail(landmark: landmark)
//                } label:{
//                    LandmarkRow(landmark: landmark)
//                }
//            }
//            .navigationTitle("Landmarks")
//        }
//    }
//}
//
//struct LandmarkList_Previews: PreviewProvider {
//    static var previews: some View {
//       ForEach(["iPhone SE (2nd Generation)", "iPhone XS Max", "iPad Pro (12.9-inch) (2nd Generation)"], id:\.self){ deviceName in
//            LandmarkList()
//                .previewDevice(PreviewDevice(rawValue: deviceName))
//                .previewDisplayName(deviceName)}
//    }
//}
