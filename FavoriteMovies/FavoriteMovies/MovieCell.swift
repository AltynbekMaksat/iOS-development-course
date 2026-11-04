import UIKit

final class MovieCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    
    
    @IBOutlet weak var ratingStackView: UIStackView!
    
    
    

    func configure(
        title: String,
        genre: String,
        posterName: String,
        rating: Int
    ) {
        titleLabel.text = title
        genreLabel.text = genre
        posterImageView.image = UIImage(named: posterName)

        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            guard let imageView = view as? UIImageView else { continue }

            let symbol = index < rating ? "star.fill" : "star"
            imageView.image = UIImage(systemName: symbol)
        }
    }
}
    
