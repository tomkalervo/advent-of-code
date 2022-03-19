# Solution
After finding the center of all the basins I decided to use a recursive divide-n-conquer approach to find the size of the basin. The idea is as follows: If the point we are at belongs to the basin (i.e not outside the frame, not a '9' or not already checked) we continue to check its surrounding points. This is done recursivly until no more points belong to the basin.