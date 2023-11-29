/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Help and tutorial views.
*/
import SwiftUI

/// This method implements a tabbed tutorial view that the app displays when the user presses the help button.
struct HelpPageView: View {
    var body: some View {
        ZStack {
            Color(red: 0, green: 0, blue: 0.01, opacity: 1.0)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            TabView {
                ObjectHelpPageView()
                PhotographyHelpPageView()
                EnvironmentHelpPageView()
            }
            .tabViewStyle(PageTabViewStyle())
        }
        .navigationTitle("Scanning Info")
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TutorialPageView: View {
    let pageName: String
    let imageName: String
    let imageCaption: String
    
    var body: some View {
        GeometryReader { geomReader in
            VStack {
                Spacer()
                
                Image(systemName:imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 0.1 * geomReader.size.width)

                Spacer()
              
                Text(imageCaption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                    // Pad the view a total of 25% (12.5% on each side).
                    .padding(.horizontal, geomReader.size.width / 12.5)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(width: geomReader.size.width, height: geomReader.size.height)
        }
        .navigationBarTitle(pageName, displayMode: .inline)
    }
}

struct ObjectHelpPageView: View {
    var body: some View {
        TutorialPageView(pageName: "Terrain Types",
                         imageName: "mountain.2.fill",
                         imageCaption: "Choose the terrain type to pre-classify this set of images.")
    }
}

struct PhotographyHelpPageView: View {
    var body: some View {
        TutorialPageView(pageName: "Device Gravity Vector",
                         imageName: "arrow.down.to.line",
                         imageCaption: "Will capture a gravity vector with each image providing device orientation.")
    }
}

struct EnvironmentHelpPageView: View {
    var body: some View {
        TutorialPageView(pageName: "Depth Data",
                         imageName: "square.3.layers.3d.top.filled",
                         imageCaption: "Capture LiDAR or Stereoscopic image depth data into separate file.")
    }
}

#if DEBUG
struct HelpPageView_Previews: PreviewProvider {
    static var previews: some View {
        HelpPageView()
    }
}
#endif // DEBUG
