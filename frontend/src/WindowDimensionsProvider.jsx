import React, {
  createContext, useContext, useState, useEffect,
} from 'react';

export const WindowDimensionsContext = createContext(null);

const tabletWidth = 1280;

const windowDimensions = () => ({
  height: window.innerHeight,
  width: window.innerWidth,
  tablet: window.innerWidth <= tabletWidth,
});

// eslint-disable-next-line react/prop-types
const WindowDimensionsProvider = ({ children }) => {
  const [dimensions, setDimensions] = useState(windowDimensions());
  useEffect(() => {
    const handleResize = () => {
      setDimensions(windowDimensions());
    };
    window.addEventListener('resize', handleResize);
    return () => { window.removeEventListener('resize', handleResize); };
  }, []);
  return (
    <WindowDimensionsContext.Provider value={dimensions}>
      {children}
    </WindowDimensionsContext.Provider>
  );
};

export default WindowDimensionsProvider;

export const useWindowDimensions = () => useContext(WindowDimensionsContext);

/* SAMPLE USAGE
import React from 'react';
import { useWindowDimensions } from '../../WindowDimensionsProvider';

const SampleComponent = () => {
  const { tablet } = useWindowDimensions();

  return (
    {tablet ?
      <div>Screen width is {tabletWidth} or smaller</div> :
      <div>Screen width is larger than {tabletWidth}}</div>
    }
  )
}
 */
