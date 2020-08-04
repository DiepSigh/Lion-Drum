using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Advertisements;

public class MakeMeMoney : MonoBehaviour
{

    string game_ID = "3744029"
    bool testMode = true;

    // Start is called before the first frame update
    void Start()
    {
        Advertisement.Initialize(game_ID, testMode);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
