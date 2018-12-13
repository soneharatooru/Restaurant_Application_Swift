

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    // For exercise #1
    @IBOutlet var restaurantImageView: UIImageView!
    var restaurant:RestaurantMO?
    
    // For exercise #2
    @IBOutlet var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Solution to Exercise #1 - Start here
        if let restaurant = restaurant {
            restaurantImageView.image = UIImage(data: restaurant.image as! Data)
        }
        // Solution to Exercise #1 - End here
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        // View animation
        let scaleTransform = CGAffineTransform.init(scaleX: 0, y: 0)
        let translateTransform = CGAffineTransform.init(translationX: 0, y: -1000)
        let combineTransform = scaleTransform.concatenating(translateTransform)
        containerView.transform = combineTransform
        
        // Solution to Exercise #2 - Start here
        closeButton.transform = CGAffineTransform.init(translationX: 1000, y: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
        // Solution to Exercise #2
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            
            self.closeButton.transform = CGAffineTransform.identity
            
            }, completion: nil)
        
     /*   UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity

            }, completion: nil)*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
