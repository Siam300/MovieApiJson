//
//  FavMovie.swift
//  MovieApiJson
//
//  Created by Auto on 8/15/23.
//

import SwiftUI

struct URLImage: View {
    let urlString: String
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 70)
        }
        else {
            Image("")
                .resizable()
                .frame(width: 130, height: 70)
                .aspectRatio(contentMode: .fill)
                .onAppear{
                    getData()
                }
        }
    }
    private func getData() {
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            self.data = data
        }
        task.resume()
    }
}


struct movieModel: Hashable, Codable {
    let name: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case image
    }
}

class movieViewModel: ObservableObject {
    @Published var movies: [movieModel] = []
    
    init() {
        getData()
    }
    
    func getData() {
        guard let url = URL(string: "https://iosacademy.io/api/v1/courses/index.php") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data,
                  error == nil
            else{
                print("Error!!")
                return
            }
            guard let newMovie = try? JSONDecoder().decode([movieModel].self, from: data) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.movies = newMovie
            }
        }.resume()
    }
}


struct FavMovie: View {
    
    @StateObject var vm = movieViewModel()
    
    var body: some View {
        NavigationView {
            List {
                LazyVStack {
                    ForEach(vm.movies, id:\.self) { item in
                        HStack() {
                            URLImage(urlString: item.image)
                            Text("Name: \(item.name).") .padding(3)
                        }
                        .padding(20)
                    }
                }
                .navigationTitle("Favorite Movies")
            }
            .listStyle(.inset)
        }
    }
}

struct FavMovie_Previews: PreviewProvider {
    static var previews: some View {
        FavMovie()
    }
}
