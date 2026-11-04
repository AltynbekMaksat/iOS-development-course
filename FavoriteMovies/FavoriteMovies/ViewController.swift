import UIKit

struct Movie {
    let title: String
    let genre: String
    let posterName: String
    let rating: Int
}

final class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!


    private let movies: [Movie] = [
        Movie(title: "Inception", genre: "Sci-Fi", posterName: "inception", rating: 5),
        Movie(title: "Interstellar", genre: "Sci-Fi", posterName: "interstellar", rating: 5),
        Movie(title: "The Dark Knight", genre: "Action", posterName: "darkKnight", rating: 5),
        Movie(title: "The Matrix", genre: "Sci-Fi", posterName: "matrix", rating: 5),
        Movie(title: "Parasite", genre: "Thriller", posterName: "parasite", rating: 5),
        Movie(title: "Spirited Away", genre: "Animation", posterName: "spiritedAway", rating: 5),
        Movie(title: "The Grand Budapest Hotel", genre: "Comedy", posterName: "grandBudapest", rating: 4),
        Movie(title: "Whiplash", genre: "Drama", posterName: "whiplash", rating: 5),
        Movie(title: "Dune", genre: "Sci-Fi", posterName: "Dune", rating: 4),
        Movie(title: "Arrival", genre: "Sci-Fi", posterName: "Arrival", rating: 5),
        Movie(title: "Pulp Fiction", genre: "Crime", posterName: "pulpFiction", rating: 5),
        Movie(title: "Forrest Gump", genre: "Drama", posterName: "forrestGump", rating: 5),
        Movie(title: "Coco", genre: "Animation", posterName: "coco", rating: 5),
        Movie(title: "The Lion King", genre: "Animation", posterName: "lionKing", rating: 4),
        Movie(title: "Gladiator", genre: "Action", posterName: "gladiator", rating: 4),
        Movie(title: "Titanic", genre: "Romance", posterName: "titanic", rating: 4),
        Movie(title: "The Truman Show", genre: "Drama", posterName: "trumanShow", rating: 5),
        Movie(title: "Amélie", genre: "Romance", posterName: "amelie", rating: 4),
        Movie(title: "Up", genre: "Animation", posterName: "up", rating: 5),
        Movie(title: "The Social Network", genre: "Drama", posterName: "socialNetwork", rating: 4)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 180
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MovieCell",
            for: indexPath
        ) as! MovieCell

        let movie = movies[indexPath.row]
        cell.configure(
            title: movie.title,
            genre: movie.genre,
            posterName: movie.posterName,
            rating: movie.rating
        )
        return cell
    }
}
