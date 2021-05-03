const randString = () => Math.random().toString(36).substr(7);

const randObjVal = (obj) => {
  const keysArray = Object.keys(obj);
  const randomIndex = Math.floor(Math.random() * keysArray.length);
  const randomKey = keysArray[randomIndex];
  const randomValue = obj[randomKey];

  return randomValue;
};

const utils = {
  randString,
  randObjVal,
};

export default utils;
