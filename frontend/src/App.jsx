import './App.css';
import { useState, useRef, useEffect } from 'react';

const URL = 'http://18.117.100.93/';

function App() {
  const [hiddenPercent, setHiddenPercent] = useState(0);
  const intervalRef = useRef(null); // Ref to track the interval ID
  const [trainData, setTrainData] = useState([]); // State to store the list of trains
  const [currentPlot, setCurrentPlot] = useState(null); // Store the current plot data
  const [initialLoad, setInitialLoad] = useState(true);

  // Fetch train data from the backend API
  useEffect(() => {
    const fetchTrainData = async () => {
      try {
        const response = await fetch(URL + "api/trains/");
        const data = await response.json();
        setTrainData(data); // Update state with the received train data
        if (initialLoad) {
          setCurrentPlot(data[0]);
          setInitialLoad(false);
        }
        
      } catch (error) {
        console.error('Error fetching train data:', error);
      }
    };

    fetchTrainData();
    console.log("data fetched!");
  }, [currentPlot]); // This will run once when the component mounts

  const handleAnimate = (start) => {
    // Clear any existing interval to prevent multiple animations
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    setHiddenPercent(start); // Start at 100%

    intervalRef.current = setInterval(() => {
      setHiddenPercent((prev) => {
        if (prev <= 0) {
          clearInterval(intervalRef.current); // Stop the interval
          intervalRef.current = null; // Reset the ref
          return 0; // Ensure it stops at 0
        }
        return prev - 0.05; // Decrease hiddenPercent steadily
      });
    }, 18); // Adjust the interval (in milliseconds) to control the speed
  };

  const handleTrainClick = (trainId) => {
    // Clear the animation if it's running
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null; // Reset the interval reference
    }
    // Find the clicked train and update the plot
    const selectedTrain = trainData.find(train => train.id === trainId);
    setCurrentPlot(selectedTrain);
    setHiddenPercent(0);
  };

  return (
    <div className="app-container">
      <div className="train-links">
      <button className="animate-button" onClick={() => handleAnimate(currentPlot?.animation_start * 0.93)}>
        Animate
      </button>
        {trainData.map((train) => (
          <button
            key={train.id}
            className={`train-button ${train.id === currentPlot?.id ? 'highlighted' : ''}`}
            onClick={() => handleTrainClick(train.id)}
          >
            {`${train.id}`}
          </button>
        ))}
      </div>

      <div className="image-container">
        {/* Display background and foreground images based on selected train */}
        {currentPlot && (
          <>
            <img
              src={URL + currentPlot.background_img}
              alt="Background Plot"
              className="background-image"
            />
            <img
              src={URL + currentPlot.foreground_img}
              alt="Foreground Plot"
              style={{ clipPath: `inset(0 ${hiddenPercent}% 0 0)` }}
              className="foreground-image"
            />
          </>
        )}
      </div>
    </div>
  );
}

export default App;
