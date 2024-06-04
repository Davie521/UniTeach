//
//  ProfileView.swift
//  Teach
//
//  Created by Davie on 04/06/2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text("Name: Davie")
                .font(.title2)
                .padding()
            Text("University: University of Edinburgh")
                .font(.title2)
                .padding()
    
            Text("Tags: Math, Physics")
                .font(.title2)
                .padding()
            Text("Availability: 9am - 5pm")
                .font(.title2)
                .padding()
            //
        }
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
