import './App.css';
import { useState, useRef, useEffect } from 'react';

const URL = 'https://chaser164.github.io/amtrak-live/';

function App() {
  const [hiddenPercent, setHiddenPercent] = useState(0);
  const intervalRef = useRef(null); // Ref to track the interval ID
  const [trainData, setTrainData] = useState([]); // State to store the list of trains
  const [currentPlot, setCurrentPlot] = useState(null); // Store the current plot data

  // Fetch train data on initial load
  useEffect(() => {
    const fetchTrainData = async () => {
      try {
        const response = await fetch(URL + 'api/trains.json');
        const data = await response.json();
        setTrainData(data); // Update state with the received train data
        if (data.length > 0) {
          setCurrentPlot(data[0]); // Set the first train as the initial plot
        }
      } catch (error) {
        console.error('Error fetching train data:', error);
      }
    };

    fetchTrainData(); // Fetch data once on initial load
  }, []); // Empty dependency array ensures this runs once

  const handleAnimate = (start) => {
    // Clear any existing interval to prevent multiple animations
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }

    setHiddenPercent(start); // Start animation at the given percent

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

  const handleTrainClick = async (trainId) => {
    // Clear the animation if it's running
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null; // Reset the interval reference
    }

    try {
      const response = await fetch(URL + 'api/trains.json');
      const data = await response.json();
      setTrainData(data); // Refresh train data

      // Find the clicked train and update the plot
      const selectedTrain = data.find((train) => train.id === trainId);
      if (selectedTrain) {
        setCurrentPlot(selectedTrain); // Update current plot
      }
      setHiddenPercent(0);
    } catch (error) {
      console.error('Error fetching train data on click:', error);
      setHiddenPercent(0);
    }
  };

  return (
    <div className="app-container">
      <div className="train-links">
        <h1><em>Amtrak Live</em></h1>
        <p>Visualizing Amtrak's Northeast Corridor</p>
        <button
          className="animate-button"
          onClick={() => handleAnimate(currentPlot?.animation_start * 0.885)}
        >
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
              <div className="footer">
        <p>
          Data sourced from <a href="https://github.com/piemadd/amtrak" target="_blank" rel="noopener noreferrer">here</a>. 
          This site is not affiliated with Amtrak and makes no guarantees 
for data accuracy. Your data is not collected.
        </p>
      </div>
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
