import SwiftUI
import Combine

// 0. DEFINIMOS QUÉ ES UN PEZ PRIMERO (Para que Xcode lo conozca)
struct Pez: Hashable, Equatable {
    var nombre: String
    var color: Color
}

// 1. LA CAJA COMPARTIDA (Lógica de favoritos)
class GestorFavoritos: ObservableObject {
    @Published var pecesGuardados: [Pez] = []
    
    func alternarFavorito(pez: Pez) {
        if let index = pecesGuardados.firstIndex(of: pez) {
            pecesGuardados.remove(at: index)
        } else {
            pecesGuardados.append(pez)
        }
    }
}

// 2. EL MENÚ PRINCIPAL
struct ContentView: View {
    @StateObject var gestorFavoritos = GestorFavoritos()
    
    var body: some View {
        TabView {
            PantallaPrincipal()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            PantallaFavoritos()
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }
        }
        .accentColor(.cyan)
        .environmentObject(gestorFavoritos)
    }
}

// 3. PANTALLA DE INICIO
struct PantallaPrincipal: View {
    @State private var textoBusqueda: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.1, blue: 0.3), Color.blue]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Happy Fish =]")
                        .font(.title).bold().padding(.horizontal).padding(.top, 20).foregroundStyle(.white)
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Busca un pescado...", text: $textoBusqueda).font(.body)
                    }
                    .padding().background(Color(.systemGray6)).cornerRadius(20).padding(.horizontal)
                    
                    Text("Zonas Pesqueras")
                        .font(.title2).bold().padding(.horizontal).padding(.top, 20).foregroundStyle(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            NavigationLink(destination: VistaZona(nombreZona: "Alaska")) {
                                TarjetaCategoria(icono: "mappin.and.ellipse", nombre: "Alaska", color: .blue)
                            }
                            NavigationLink(destination: VistaZona(nombreZona: "Golfo de México")) {
                                TarjetaCategoria(icono: "mappin.and.ellipse", nombre: "Golfo de MX", color: .teal)
                            }
                            NavigationLink(destination: VistaZona(nombreZona: "Nueva Inglaterra")) {
                                TarjetaCategoria(icono: "mappin.and.ellipse", nombre: "N. Inglaterra", color: .indigo)
                            }
                        }
                        .padding(.horizontal).padding(.top, 5)
                    }
                    
                    // Explicación del Semáforo
                    VStack(alignment: .leading, spacing: 12) {
                        Text("¿Cómo funciona el semáforo?")
                            .font(.headline).foregroundColor(.white).padding(.bottom, 5)
                        
                        HStack {
                            Circle().fill(Color.green).frame(width: 15, height: 15)
                            Text("Verde: Pesca permitida y abundante.").foregroundColor(.white).font(.subheadline)
                        }
                        HStack {
                            Circle().fill(Color.yellow).frame(width: 15, height: 15)
                            Text("Amarillo: Especie regulada (precaución).").foregroundColor(.white).font(.subheadline)
                        }
                        HStack {
                            Circle().fill(Color.red).frame(width: 15, height: 15)
                            Text("Rojo: Especie protegida o prohibida.").foregroundColor(.white).font(.subheadline)
                        }
                    }
                    .padding(.horizontal).padding(.top, 25)
                    Spacer()
                }
            }
        }
    }
}

// 4. PANTALLA DE ZONA (SEMÁFORO)
struct VistaZona: View {
    var nombreZona: String
    @EnvironmentObject var favoritos: GestorFavoritos
    
    var pecesAmostrar: [Pez] {
        if nombreZona == "Golfo de México" {
            return [
                Pez(nombre: "Dorado (Mahi-Mahi)", color: .green),
                Pez(nombre: "Lisa Rayada (Mullet)", color: .green),
                Pez(nombre: "Huachinango del Golfo", color: .yellow),
                Pez(nombre: "Marlín Azul del Atlántico", color: .yellow),
                Pez(nombre: "Pez Sierra (Dientes Pequeños)", color: .red),
                Pez(nombre: "Mero de Nassau", color: .red)
            ]
        } else {
            return [Pez(nombre: "Especies no registradas aún", color: .gray)]
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.3).ignoresSafeArea()
            
            VStack {
                Text("Especies en \(nombreZona)")
                    .font(.title).bold().foregroundColor(.white).padding(.top, 20)
                
                List(pecesAmostrar, id: \.nombre) { pez in
                    HStack {
                        Circle().fill(pez.color).frame(width: 20, height: 20)
                        
                        Text(pez.nombre).font(.headline).foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            favoritos.alternarFavorito(pez: pez)
                        }) {
                            Image(systemName: favoritos.pecesGuardados.contains(pez) ? "heart.fill" : "heart")
                                .foregroundColor(favoritos.pecesGuardados.contains(pez) ? .red : .gray)
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.blue.opacity(0.3))
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

// 5. PANTALLA DE FAVORITOS
struct PantallaFavoritos: View {
    @EnvironmentObject var favoritos: GestorFavoritos
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.0, green: 0.1, blue: 0.3).ignoresSafeArea()
                
                if favoritos.pecesGuardados.isEmpty {
                    Text("Aún no tienes peces favoritos.")
                        .foregroundColor(.gray)
                } else {
                    List(favoritos.pecesGuardados, id: \.nombre) { pez in
                        HStack {
                            Circle().fill(pez.color).frame(width: 15, height: 15)
                            Text(pez.nombre).font(.headline).foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                favoritos.alternarFavorito(pez: pez)
                            }) {
                                Image(systemName: "heart.fill").foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .listRowBackground(Color.blue.opacity(0.3))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Mis Favoritos")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// 6. COMPONENTE DE TARJETA
struct TarjetaCategoria: View {
    var icono: String; var nombre: String; var color: Color
    var body: some View {
        VStack {
            Image(systemName: icono).font(.largeTitle).foregroundColor(.white).padding(.bottom, 5)
            Text(nombre).font(.headline).foregroundColor(.white)
        }
        .frame(width: 125, height: 110).background(color).cornerRadius(20)
    }
}

#Preview {
    ContentView()
}
