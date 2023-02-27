import matplotlib.pyplot as plt

x = [10,20,30,40,50]
y = [0,0.001,0.003,0.007,0.06]

plt.plot(x, y,marker='o')
plt.xlabel('Flow Count')
plt.ylabel('Drop Ratio')
plt.title('Drop Ratio\nvs\nFlow Count')
plt.grid(color = 'green', linestyle = '--', linewidth = 0.5)
plt.show()
